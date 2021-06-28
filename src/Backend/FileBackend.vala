/***

    Copyright (C) 2014-2021 Agenda Developers

    This file is part of Agenda.

    Agenda is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Agenda is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Agenda.  If not, see <http://www.gnu.org/licenses/>.

***/

namespace Agenda {
    public class FileBackend : GLib.Object, Backend {

        private File task_file;
        private File history_file;

        public FileBackend () {
            string user_data = Environment.get_user_data_dir ();

            File dir = File.new_for_path (user_data).get_child ("agenda");

            try {
                dir.make_directory_with_parents ();
            } catch (Error e) {
                if (e is IOError.EXISTS) {
                    info ("%s", e.message);
                } else {
                    error ("Could not access or create directory '%s'.",
                           dir.get_path ());
                }
            }

            task_file = dir.get_child ("tasks");
            history_file = dir.get_child ("history");
        }

        public string[] load_history () {
            string[] history = {};

            try {
                string line;
                var file_input_stream = history_file.read ();
                var f_dis = new DataInputStream (file_input_stream);

                while ((line = f_dis.read_line (null)) != null) {
                    history += line;
                }
            } catch (Error e) {
                if (e is IOError.NOT_FOUND) {
                    info ("%s", e.message);
                } else {
                    error ("%s", e.message);
                }
            }

            return history;
        }

        public Task[] load_tasks () {
            Task[] tasks = {};

            try {
                string line;
                var file_input_stream = task_file.read ();
                var f_dis = new DataInputStream (file_input_stream);

                while ((line = f_dis.read_line (null)) != null) {
                    var task_line = line.split (",", 2);
                    Task task = new Task ();
                    task.text = task_line[1];

                    if (task_line[0] == "t") {
                        task.complete = true;
                    } else {
                        task.complete = false;
                    }
                    tasks += task;
                }
            } catch (Error e) {
                if (e is IOError.NOT_FOUND) {
                    info ("%s", e.message);
                } else {
                    error ("%s", e.message);
                }
            }

            return tasks;
        }

        public void save_history (string[] history) {
            save_to_file (history, history_file);
        }

        public void save_tasks (Task[] tasks) {
            string[] lines = {};

            foreach (Task task in tasks) {
                lines += task.to_string ();
            }

            save_to_file (lines, task_file);
        }

        private void save_to_file (string[] lines, File file) {
            try {
                var file_fos = file.replace (null, false, FileCreateFlags.NONE);
                var file_dos = new DataOutputStream (file_fos);
                foreach (string line in lines) {
                    file_dos.put_string (line + "\n");
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }
    }
}

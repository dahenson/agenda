/***

    Copyright (C) 2014-2020 Agenda Developers

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

            if (!dir.query_exists ()) {
                try {
                    dir.make_directory_with_parents ();
                } catch {
                    error ("Could not access or create directory '%s'.",
                           dir.get_path ());
                }
            }

            task_file = dir.get_child ("tasks");
            ensure_file_exists (task_file);

            history_file = dir.get_child ("history");
            ensure_file_exists (history_file);
        }

        public string[] load_history () {
            string[] history = {};

            try {
                string line;
                var f_dis = new DataInputStream (history_file.read ());

                while ((line = f_dis.read_line (null)) != null) {
                    history += line;
                }
            } catch (Error e) {
                error ("%s", e.message);
            }

            return history;
        }

        public Task[] load_tasks () {
            Task[] tasks = {};

            try {
                string line;
                var f_dis = new DataInputStream (task_file.read ());

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
                error ("%s", e.message);
            }

            return tasks;
        }

        public void save_history (string[] history) {
            try {
                if (history_file.query_exists ()) {
                    history_file.delete ();
                }

                var history_dos = new DataOutputStream (
                    history_file.create (FileCreateFlags.REPLACE_DESTINATION));
                foreach (string line in history) {
                    history_dos.put_string (line + "\n");
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }

        public void save_tasks (Task[] tasks) {
            try {
                if (task_file.query_exists ()) {
                    task_file.delete ();
                }

                var file_dos = new DataOutputStream (
                    task_file.create (FileCreateFlags.REPLACE_DESTINATION));
                foreach (Task task in tasks) {
                    file_dos.put_string (task.to_string () + "\n");
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }

        private void ensure_file_exists (File file) {
            if ( !file.query_exists () ) {
                try {
                    task_file.create (FileCreateFlags.NONE);
                } catch (Error e) {
                    error ("Error: %s\n", e.message);
                }
            }
        }
    }
}

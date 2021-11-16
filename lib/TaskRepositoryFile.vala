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

    public class TaskRepositoryFile : GLib.Object, ITaskRepository, GLib.ListModel {

        private GLib.File task_file;
        private TaskList task_list;

        public TaskRepositoryFile (GLib.File agenda_dir) {
            this.task_file = agenda_dir.get_child ("tasks");

            this.task_list = load ();
        }

        public void add (Task task) {
            this.task_list.add (task);
            this.save ();

            this.items_changed (this.task_list.size - 1, 0, 1);
        }

        public TaskList get_all () {
            return this.task_list;
        }

        public Task? get_by_id (int index) {
            if (index > this.task_list.size) {
                return null;
            }

            return this.task_list.@get (index);
        }

        public Object? get_item (uint position) {
            if (position > this.task_list.size) {
                return null;
            }

            return this.task_list.@get ((int) position);
        }

        public Type get_item_type () {
            return typeof (Task);
        }

        public uint get_n_items () {
            return (uint) this.task_list.size;
        }

        public bool remove (Task task) {
            var removed = this.task_list.remove (task);
            if (removed) {
                this.items_changed (0, 1, 0);
                this.save ();
            }

            return removed;
        }

        public void update (int index, Task task) {
            this.task_list.@set(index, task);
            this.save ();
        }

        private TaskList load () {
            var list = new TaskList ();

            try {
                string line;
                var file_input_stream = task_file.read ();
                var f_dis = new DataInputStream (file_input_stream);

                while ((line = f_dis.read_line (null)) != null) {
                    Task task = new Task.from_string (line);

                    list.add (task);
                }
            } catch (Error e) {
                if (e is IOError.NOT_FOUND) {
                    info ("%s", e.message);
                } else {
                    error ("%s", e.message);
                }
            }

            return list;
        }

        private void save () {
            try {
                var file_fos = task_file.replace (null, false, FileCreateFlags.NONE);
                var file_dos = new DataOutputStream (file_fos);
                foreach (Task task in task_list) {
                    file_dos.put_string (task.to_string () + "\n");
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }

    }

}

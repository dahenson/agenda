/***

    Copyright (C) 2014-2022 Agenda Developers

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

    public class Action : GLib.Object {
        public enum Type {
            ADD,
            DELETE,
            UPDATE,
            NOOP
        }

        public Type action_type { public get; construct set; }
        public Task? task { public get; construct set; }
        public int index { public get; construct set; }

        public Action (Type type, Task? task, int index) {
            Object (action_type: type, task: task, index: index);
        }
    }

    public class TaskRepositoryFile : GLib.Object, ITaskRepository, GLib.ListModel {

        private GLib.File task_file;
        private Gee.LinkedList<Task> task_list;
        private Gee.LinkedList<Action> action_list;
        private Gee.BidirListIterator<Action> action_iter;

        public TaskRepositoryFile (GLib.File file) {
            task_file = file;

            load ();
        }

        construct {
            task_list = new Gee.LinkedList<Task> ((Gee.EqualDataFunc) Task.eq);
            action_list = new Gee.LinkedList<Action> ();
            action_list.add (
                new Action (Action.Type.NOOP, null, 0));

            action_iter = action_list.bidir_list_iterator ();
            action_iter.next ();
        }

        public void add (Task task) {
            task_list.add (task);
            action_list.add (
                new Action (Action.Type.ADD, task, task_list.size - 1));
            action_iter.next ();

            save ();

            items_changed (task_list.size - 1, 0, 1);
        }

        public Gee.LinkedList<Task> get_all () {
            return task_list;
        }

        public Task? get_by_id (int index) {
            if (index > task_list.size) {
                return null;
            }

            return task_list.@get (index);
        }

        public Object? get_item (uint position) {
            if (position > task_list.size) {
                return null;
            }

            return task_list.@get ((int) position);
        }

        public Type get_item_type () {
            return typeof (Task);
        }

        public uint get_n_items () {
            return (uint) task_list.size;
        }

        public bool remove (Task task) {
            var index = task_list.index_of (task);
            var removed = task_list.remove (task);
            if (removed) {
                items_changed (index, 1, 0);
                save ();
            }

            return removed;
        }

        public void undo () {
            var action = action_iter.@get ();

            switch (action.action_type) {
                case Action.Type.ADD:
                    task_list.remove_at (action.index);
                    items_changed (action.index, 1, 0);
                    break;
                default:
                    return;
            }

            action_iter.previous ();
        }

        public void update (int index, Task task) {
            this.task_list.@set(index, task);
            save ();
        }

        private void load () {
            task_list.clear ();

            try {
                string line;
                var file_input_stream = task_file.read ();
                var f_dis = new DataInputStream (file_input_stream);

                while ((line = f_dis.read_line (null)) != null) {
                    Task task = new Task.from_string (line);

                    task_list.add (task);
                }
            } catch (Error e) {
                if (e is IOError.NOT_FOUND) {
                    info ("%s", e.message);
                } else {
                    error ("%s", e.message);
                }
            }
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

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

    public class TaskList : Gtk.ListStore {

        public signal void list_changed ();

        public enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DELETE,
            DRAGHANDLE,
            ID,
            N_COLUMNS
        }

        private TaskListHistory undo_list;

        private bool record_undo_enable {
            private get;
            private set;
            default = true;
        }

        public int size {
            public get { return iter_n_children (null); }
        }

        construct {
            undo_list = new TaskListHistory ();

            Type[] types = {
                typeof (bool),
                typeof (string),
                typeof (bool),
                typeof (string),
                typeof (string),
                typeof (string)
            };

            set_column_types (types);

            row_changed.connect (on_row_changed);
            row_deleted.connect (on_row_deleted);
        }

        /**
         * Add a task to the end of the task list
         *
         * @param task The task being appended to the list
         */
        public void append_task (Task task) {
            Gtk.TreeIter iter;

            if (task.id == "") {
                task.id = Uuid.string_random ();
            }

            append (out iter);
            set (iter,
                 Columns.TOGGLE, task.complete,
                 Columns.TEXT, task.text,
                 Columns.STRIKETHROUGH, task.complete,
                 Columns.DELETE, "edit-delete-symbolic",
                 Columns.DRAGHANDLE, "view-list-symbolic",
                 Columns.ID, task.id);

            list_changed ();
        }

        public void clear_undo () {
            undo_list = new TaskListHistory ();
            undo_list.add (this);
        }

        /**
         * Test if the list contains a task with specific id
         *
         * @param id The id of the task
         */
        public bool contains (string id) {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);

            while (valid) {
                string list_id;
                get (iter, TaskList.Columns.ID, out list_id);

                if (list_id == id) {
                    return true;
                } else {
                    valid = iter_next (ref iter);
                }
            }

            return false;
        }

        /**
         * Return a copy of the list
         */
        public TaskList copy () {
            TaskList list_copy = new TaskList ();
            Task[] tasks = get_all_tasks ();

            list_copy.load_tasks (tasks);

            return list_copy;
        }

        public void disable_undo_recording () {
            record_undo_enable = false;
        }

        public void enable_undo_recording () {
            record_undo_enable = true;
        }

        /**
         * Gets all tasks in the list
         *
         * @return Array of tasks
         */
        public Task[] get_all_tasks () {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);

            Task[] tasks = {};

            while (valid) {
                Task task = get_task (iter);
                tasks += task;
                valid = iter_next (ref iter);
            }

            return tasks;
        }

        public Task get_task (Gtk.TreeIter iter) {
            string id;
            bool complete;
            string text;

            this.get (iter,
                      Columns.ID, out id,
                      Columns.TOGGLE, out complete,
                      Columns.TEXT, out text);

            return new Task.with_attributes (id, complete, text);
        }

        public bool has_duplicates_of (string id) {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);
            int count = 0;

            while (valid) {
                string list_id;
                get (iter, TaskList.Columns.ID, out list_id);

                if (list_id == id)
                    count++;
                valid = iter_next (ref iter);
            }

            if (count > 1)
                return true;
            else
                return false;
        }

        /**
         * Gets if the task list is empty or not
         *
         * @return True if the list is empty
         */
        public bool is_empty () {
            Gtk.TreeIter iter;
            return !get_iter_first (out iter);
        }

        public void load_tasks (Task[] tasks) {
            foreach (Task task in tasks) {
                this.insert_with_values (null, -1,
                     Columns.TOGGLE, task.complete,
                     Columns.TEXT, task.text,
                     Columns.STRIKETHROUGH, task.complete,
                     Columns.DELETE, "edit-delete-symbolic",
                     Columns.DRAGHANDLE, "view-list-symbolic",
                     Columns.ID, task.id);
            }
        }

        private void on_row_changed (Gtk.TreePath path, Gtk.TreeIter iter) {
            string list_id;

            get (iter, TaskList.Columns.ID, out list_id);
            if (record_undo_enable && !has_duplicates_of (list_id)) {
                undo_list.add (this);
                list_changed ();
            }
        }

        private void on_row_deleted (Gtk.TreePath path) {
            /**
             * This takes care of when a row is removed, and also when
             * a row is reordered through drag and drop.
             */
            if (record_undo_enable)
                undo_list.add (this);
                list_changed ();
        }

        public bool remove_task (Gtk.TreePath path) {
            Gtk.TreeIter iter;
            string id;
            string text;

            if (get_iter (out iter, path)) {
                get (iter, Columns.ID, out id, Columns.TEXT, out text);
#if VALA_0_36
                remove (ref iter);
#else
                remove (iter);
#endif

                return true;
            } else {
                return false;
            }
        }

        public void remove_completed_tasks () {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);
            bool active;
            int counter = 0;

            while (valid) {
                get (iter, Columns.TOGGLE, out active);

                if (active) {
#if VALA_0_36
                    remove (ref iter);
#else
                    remove (iter);
#endif
                    valid = get_iter_first (out iter);
                    counter++;
                } else {
                    valid = iter_next (ref iter);
                }
            }

            list_changed ();
        }

        public void redo () {
            var state = undo_list.get_next_state ();

            if (state != null)
                restore_state (state);
        }

        public void undo () {
            var state = undo_list.get_previous_state ();

            if (state != null)
                restore_state (state);
        }

        private void restore_state (TaskList state) {
            disable_undo_recording ();
            this.clear ();

            Task[] tasks = state.get_all_tasks ();

            this.load_tasks (tasks);

            enable_undo_recording ();
            list_changed ();
        }

        public void set_task_text (string path, string text) {
            Gtk.TreeIter iter;
            var tree_path = new Gtk.TreePath.from_string (path);

            get_iter (out iter, tree_path);
            set (iter, TaskList.Columns.TEXT, text);
        }

        public void toggle_task (Gtk.TreePath path) {
            bool toggle;
            Gtk.TreeIter iter;

            get_iter (out iter, path);

            get (iter, Columns.TOGGLE, out toggle);
            set (iter,
                TaskList.Columns.TOGGLE, !toggle,
                TaskList.Columns.STRIKETHROUGH, !toggle);

            list_changed ();
        }
    }
}

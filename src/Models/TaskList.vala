/***

    Copyright (C) 2014-2018 Agenda Developers

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

        public enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DELETE,
            DRAGHANDLE,
            ID,
            N_COLUMNS
        }

        construct {
            Type[] types = {
                typeof(bool),
                typeof(string),
                typeof(bool),
                typeof(string),
                typeof(string),
                typeof(string)
            };

            set_column_types (types);
        }

        /**
         * Add a task to the end of the task list
         *
         * @param task The string representing the task
         * @param toggled Whether the task is toggled complete or not
         */
        public string append_task (string task, bool toggled = false) {
            var id = Uuid.string_random ();
            Gtk.TreeIter iter;
            append (out iter);
            set (iter,
                Columns.TOGGLE, toggled,
                Columns.TEXT, task,
                Columns.STRIKETHROUGH, toggled,
                Columns.DELETE, "edit-delete-symbolic",
                Columns.DRAGHANDLE, "view-list-symbolic",
                Columns.ID, id);

            return id;
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
         * Gets all tasks in the list
         *
         * @return Array of tasks each prepended with 't' or 'f'
         */
        public string[] get_all_tasks () {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);

            string[] tasks = {};

            while (valid) {
                bool toggle;
                string text;
                get (iter, TaskList.Columns.TOGGLE, out toggle);
                get (iter, TaskList.Columns.TEXT, out text);
                if (toggle) {
                    text = "t," + text;
                } else {
                    text = "f," + text;
                }
                tasks += text;
                valid = iter_next (ref iter);
            }

            return tasks;
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

        public void remove_completed_tasks () {
            Gtk.TreeIter iter;
            bool valid  = get_iter_first (out iter);
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
        }
    }
}

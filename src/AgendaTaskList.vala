/***

    Copyright (C) 2014-2018 Agenda Developers

    This file is part of Agenda.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

***/

namespace Agenda {

    public class TaskList : Gtk.TreeView {

        public signal void list_changed ();

        private enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DELETE,
            DRAGHANDLE,
            N_COLUMNS
        }

        private Gtk.ListStore task_list;
        public bool is_editing;

        public TaskList() {

        }

        construct {
            name = "TaskList";
            activate_on_single_click = true;
            headers_visible = false;
            enable_search = false;
            hexpand = true;
            valign = Gtk.Align.START;
            reorderable = true;

            task_list = new Gtk.ListStore (Columns.N_COLUMNS,
                                           typeof(bool),
                                           typeof(string),
                                           typeof(bool),
                                           typeof(string),
                                           typeof(string));

            // Set up the TreeView with the necessary columns
            var column        = new Gtk.TreeViewColumn ();
            var text          = new Gtk.CellRendererText ();
            var toggle        = new Gtk.CellRendererToggle ();
            var delete_button = new Gtk.CellRendererPixbuf ();
            var draghandle    = new Gtk.CellRendererPixbuf ();

            // Setup the TOGGLE column
            toggle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Toggle",
                                                             toggle,
                                                             "active",
                                                             Columns.TOGGLE);
            append_column (column);

            // Setup the TEXT column
            text.ypad = 6;
            text.editable = true;
            text.max_width_chars = 10;
            text.ellipsize_set = true;
            text.ellipsize = Pango.EllipsizeMode.END;

            column = new Gtk.TreeViewColumn.with_attributes ("Task", text,
                "text", Columns.TEXT,
                "strikethrough", Columns.STRIKETHROUGH);
            column.expand = true;
            append_column (column);

            // Setup the DELETE column
            delete_button.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Delete", delete_button,
                "icon_name", Columns.DELETE);
            append_column(column);

            // Setup the DRAGHANDLE column
            draghandle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Drag", draghandle,
                "icon_name", Columns.DRAGHANDLE);
            append_column (column);
            model = task_list;

            set_tooltip_column (Columns.TEXT);

            text.editing_started.connect ( (editable, path) => {
                is_editing = true;
            });

            text.editing_canceled.connect ( () => {
                is_editing = false;
            });

            text.edited.connect (text_edited);
            toggle.toggled.connect (task_toggled);
            row_activated.connect (list_row_activated);

            task_list.row_deleted.connect ((path) => {
                list_changed ();
            });
        }

        /**
         * Add a task to the end of the task list
         *
         * @param task The string representing the task
         * @param toggled Whether the task is toggled complete or not
         */
        public void append_task (string task, bool toggled = false) {
            Gtk.TreeIter iter;
            task_list.append (out iter);
            task_list.set (iter,
                Columns.TOGGLE, toggled,
                Columns.TEXT, task,
                Columns.STRIKETHROUGH, toggled,
                Columns.DELETE, "edit-delete-symbolic",
                Columns.DRAGHANDLE, "view-list-symbolic");
        }

        public void toggle_selected_task () {
            Gtk.TreeIter iter;
            Gtk.TreeSelection tree_selection;
            bool current_state;

            tree_selection = get_selection ();
            tree_selection.get_selected (null, out iter);
            task_list.get (iter, 0, out current_state);

            task_list.set (iter,
                           Columns.TOGGLE, !current_state,
                           Columns.STRIKETHROUGH, !current_state);
        }

        /**
         * Gets all tasks in the list
         *
         * @return Array of tasks each prepended with 't' or 'f'
         */
        public string[] get_all_tasks () {
            Gtk.TreeIter iter;
            bool valid = task_list.get_iter_first (out iter);

            string[] tasks = {};

            while (valid) {
                bool toggle;
                string text;
                task_list.get (iter, Columns.TOGGLE, out toggle);
                task_list.get (iter, Columns.TEXT, out text);
                if (toggle) {
                    text = "t," + text;
                } else {
                    text = "f," + text;
                }
                tasks += text;
                valid = task_list.iter_next (ref iter);
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
            return task_list.get_iter_first (out iter);
        }

        /**
         * Removes all completed (toggled) tasks
         */
        public void remove_completed_tasks () {
            Gtk.TreeIter iter;
            bool valid  = task_list.get_iter_first (out iter);
            bool active;
            int counter = 0;

            while (valid) {
                task_list.get (iter, Columns.TOGGLE, out active);

                if (active) {
#if VALA_0_36
                    task_list.remove (ref iter);
#else
                    task_list.remove (iter);
#endif
                    valid = task_list.get_iter_first (out iter);
                    counter++;
                } else {
                    valid = task_list.iter_next (ref iter);
                }
            }
        }

        private void list_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            Gtk.TreeIter iter;

            task_list.get_iter (out iter, path);

            if (column.title == "Delete") {
#if VALA_0_36
                task_list.remove (ref iter);
#else
                task_list.remove (iter);
#endif
            }
        }

        /**
         * Check if the task is an empty string, or only has white space.
         *
         * @return True if task is empty
         */
        private bool task_is_empty (string task) {
            if (task == "" || (task.replace (" ", "")).length == 0) {
                return true;
            } else {
                return false;
            }
        }

        private void task_toggled (Gtk.CellRendererToggle toggle, string path) {
            var tree_path = new Gtk.TreePath.from_string (path);
            Gtk.TreeIter iter;
            task_list.get_iter (out iter, tree_path);
            task_list.set (iter,
                Columns.TOGGLE, !toggle.active,
                Columns.STRIKETHROUGH, !toggle.active);
        }

        private void text_edited (string path, string edited_text) {
            /* If the user accidentally blanks a task, abort the edit */
            if (task_is_empty (edited_text)) {
                return;
            }

            Gtk.TreeIter iter;
            task_list.get_iter (out iter, new Gtk.TreePath.from_string (path));
            task_list.set (iter, Columns.TEXT, edited_text);
            is_editing = false;
        }
    }
}

/***

    Copyright (C) 2014-2017 Agenda Developers

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses>

***/

namespace Agenda {

    public class TaskList : Gtk.TreeView {

        public signal void list_changed ();

        private enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DELETE,
            DEL_VISIBLE,
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
                                           typeof(bool),
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
                "icon_name", Columns.DELETE,
                "visible", Columns.DEL_VISIBLE);
            append_column(column);

            // Setup the DRAGHANDLE column
            draghandle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Drag", draghandle,
                "icon_name", Columns.DRAGHANDLE);
            append_column (column);
            model = task_list;

            set_tooltip_column (Columns.TEXT);

            // Method for editing tasks
            text.edited.connect ( (path, edited_text) => {
                /* If the user accidentally blanks a task, abort the edit */
                if (task_is_empty (edited_text)) {
                    return;
                }

                Gtk.TreeIter iter;
                task_list.get_iter (out iter, new Gtk.TreePath.from_string (path));
                task_list.set (iter, 1, edited_text);
                is_editing = false;
            });

            // Method for when a task is toggled (completed)
            toggle.toggled.connect ((toggle, path) => {
                var tree_path = new Gtk.TreePath.from_string (path);
                Gtk.TreeIter iter;
                task_list.get_iter (out iter, tree_path);
                task_list.set (iter,
                    Columns.TOGGLE, !toggle.active,
                    Columns.DEL_VISIBLE, !toggle.active,
                    Columns.STRIKETHROUGH, !toggle.active);
            });

            row_activated.connect ((path, column) => {
                bool deletable;
                Gtk.TreeIter iter;

                is_editing = true;
                task_list.get_iter (out iter, path);
                task_list.get (iter, Columns.TOGGLE, out deletable);

                if (column.title == "Delete" && deletable) {
#if VALA_0_36
                    task_list.remove (ref iter);
#else
                    task_list.remove (iter);
#endif
                }
            });

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
                Columns.DEL_VISIBLE, toggled,
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
                           Columns.STRIKETHROUGH, !current_state,
                           Columns.DEL_VISIBLE, !current_state);
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
    }
}
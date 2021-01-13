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

    public class TaskView : Gtk.TreeView {

        public signal void task_deleted ();
        public signal void task_added ();

        private TaskList task_list;
        public bool is_editing;

        public TaskView.with_list (TaskList list) {
            task_list = list;
            model = task_list;

            task_list.row_deleted.connect ((path) => {
                task_deleted ();
            });

            task_list.row_inserted.connect ((path) => {
                task_added ();
            });
        }

        construct {
            name = "TaskView";
            activate_on_single_click = true;
            headers_visible = false;
            enable_search = false;
            hexpand = true;
            valign = Gtk.Align.FILL;
            reorderable = true;

            var column = new Gtk.TreeViewColumn ();
            var text = new Gtk.CellRendererText ();
            var toggle = new Gtk.CellRendererToggle ();
            var delete_button = new Gtk.CellRendererPixbuf ();
            var draghandle = new Gtk.CellRendererPixbuf ();

            // Setup the TOGGLE column
            toggle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Toggle",
                                                             toggle,
                                                             "active",
                                                             TaskList.Columns.TOGGLE);
            append_column (column);

            // Setup the TEXT column
            text.ypad = 6;
            text.editable = true;
            text.max_width_chars = 10;
            text.ellipsize_set = true;
            text.ellipsize = Pango.EllipsizeMode.END;

            column = new Gtk.TreeViewColumn.with_attributes ("Task", text,
                "text", TaskList.Columns.TEXT,
                "strikethrough", TaskList.Columns.STRIKETHROUGH);
            column.expand = true;
            append_column (column);

            // Setup the DELETE column
            delete_button.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes (
                "Delete", delete_button, "icon_name", TaskList.Columns.DELETE);
            append_column (column);

            // Setup the DRAGHANDLE column
            draghandle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes (
                "Drag", draghandle, "icon_name", TaskList.Columns.DRAGHANDLE);
            append_column (column);

            set_tooltip_column (TaskList.Columns.TEXT);

            text.editing_started.connect ( (editable, path) => {
                is_editing = true;
            });

            text.editing_canceled.connect ( () => {
                is_editing = false;
            });

            text.edited.connect (text_edited);
            toggle.toggled.connect (task_toggled);
            row_activated.connect (list_row_activated);
            button_press_event.connect ((event) => {
                Gtk.TreePath p = new Gtk.TreePath ();
                get_path_at_pos ((int) event.x, (int) event.y, out p, null, null, null);
                if (p == null) {
                    get_selection ().unselect_all ();
                    p.free ();
                    return true;
                }
                p.free ();
                return false;
            });
        }

        public void toggle_selected_task () {
            Gtk.TreeIter iter;
            Gtk.TreeSelection tree_selection;
            bool current_state;

            tree_selection = get_selection ();
            tree_selection.get_selected (null, out iter);
            task_list.get (iter, 0, out current_state);

            task_list.set (iter,
                           TaskList.Columns.TOGGLE, !current_state,
                           TaskList.Columns.STRIKETHROUGH, !current_state);
        }

        private void list_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
            if (column.title == "Delete") {
                task_list.remove_task (path);
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
                TaskList.Columns.TOGGLE, !toggle.active,
                TaskList.Columns.STRIKETHROUGH, !toggle.active);
        }

        private void text_edited (string path, string edited_text) {
            /* If the user accidentally blanks a task, abort the edit */
            if (task_is_empty (edited_text)) {
                return;
            }

            Gtk.TreeIter iter;
            task_list.get_iter (out iter, new Gtk.TreePath.from_string (path));
            task_list.set (iter, TaskList.Columns.TEXT, edited_text);
            is_editing = false;
        }
    }
}

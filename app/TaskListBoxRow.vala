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

    public class TaskListBoxRow : Gtk.ListBoxRow {

        public signal void task_changed (int index, Task task);
        public signal void task_removed (Task task);

        public TaskListBoxRow (Task task) {

            var label = new Gtk.Label (task.text);
            label.set_line_wrap (true);
            label.set_justify (Gtk.Justification.FILL);
            label.set_halign (Gtk.Align.START);
            label.set_hexpand (true);

            var strike_attr = Pango.attr_strikethrough_new (task.complete);
            var attr_list = new Pango.AttrList ();
            attr_list.insert ((owned) strike_attr);
            label.set_attributes (attr_list);

            var check_button = new Gtk.CheckButton ();
            check_button.set_active (task.complete);
            check_button.toggled.connect (() => {
                task.complete = check_button.active;

                var index = this.get_index ();
                task_changed (index, task);

                strike_attr = Pango.attr_strikethrough_new (task.complete);
                attr_list.insert ((owned) strike_attr);
                label.set_attributes (attr_list);
            });

            var remove_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic");
            remove_button.clicked.connect (() => {
                task_removed (task);
            });

            var grid = new Gtk.Grid ();
            grid.set_margin_start (12);
            grid.set_margin_end (12);
            grid.set_margin_top (6);
            grid.set_margin_bottom (6);
            grid.set_column_spacing (12);

            grid.add (check_button);
            grid.add (label);
            grid.add (remove_button);

            grid.show_all ();

            this.add (grid);
        }
    }
}

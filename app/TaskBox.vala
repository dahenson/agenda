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

    public class TaskBox : Gtk.ListBox {

        public signal void update_task (int index, Task task);
        public signal void remove_task (Task task);

        public TaskBox (TaskRepositoryFile tasks) {
            this.bind_model (tasks, list_box_create_widget);
        }

        private Gtk.Widget list_box_create_widget (GLib.Object item) {
            Task task = item as Task;

            var row = new Gtk.ListBoxRow ();

            var label = new Gtk.Label (task.text) {
                wrap = true,
                justify = Gtk.Justification.LEFT,
                halign = Gtk.Align.START,
                xalign = 0,
                hexpand = true
            };

            var strike_attr = Pango.attr_strikethrough_new (task.complete);
            var attr_list = new Pango.AttrList ();
            attr_list.insert ((owned) strike_attr);
            label.set_attributes (attr_list);

            var check_button = new Gtk.CheckButton () {
                active = task.complete,
            };

            var remove_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic");

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                homogeneous = false,
                margin_start = 12,
                margin_end = 12,
                margin_top = 6,
                margin_bottom = 6,
            };

            box.append (check_button);
            box.append (label);
            box.append (remove_button);

            row.set_child (box);

            remove_button.clicked.connect (() => {
                remove_task (task);
            });

            check_button.toggled.connect (() => {
                task.complete = check_button.active;

                strike_attr = Pango.attr_strikethrough_new (task.complete);
                attr_list.insert ((owned) strike_attr);
                label.set_attributes (attr_list);

                var index = row.get_index ();
                update_task (index, task);
            });

            return row;
        }
    }
}

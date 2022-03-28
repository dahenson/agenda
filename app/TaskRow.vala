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

    public class TaskRow : Gtk.ListBoxRow {

        public signal void complete_toggled (bool complete);
        public signal void remove_task ();

        public TaskRow (string text, bool complete) {

            var label = new Gtk.Label (text) {
                wrap = true,
                justify = Gtk.Justification.LEFT,
                halign = Gtk.Align.START,
                xalign = 0,
                hexpand = true
            };

            var strike_attr = Pango.attr_strikethrough_new (complete);
            var attr_list = new Pango.AttrList ();
            attr_list.insert ((owned) strike_attr);
            label.set_attributes (attr_list);

            var check_button = new Gtk.CheckButton () {
                active = complete,
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

            this.set_child (box);
            // this.show_all ();

            remove_button.clicked.connect (() => {
                remove_task ();
            });

            check_button.toggled.connect (() => {
                complete = check_button.active;

                complete_toggled (complete);

                strike_attr = Pango.attr_strikethrough_new (complete);
                attr_list.insert ((owned) strike_attr);
                label.set_attributes (attr_list);
            });
        }
    }
}

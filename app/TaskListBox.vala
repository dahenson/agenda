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

    public class TaskListBox : Gtk.ListBox {

        public TaskListBox (TaskRepositoryFile tasks) {
            this.bind_model (tasks, list_box_create_widget);
        }

        private Gtk.Widget list_box_create_widget (GLib.Object item) {
            Task task = item as Task;

            var label = new Gtk.Label.with_mnemonic (task.text);

            var check_button = new Gtk.CheckButton ();
            check_button.set_active (task.complete);

            var grid = new Gtk.Grid ();
            grid.set_margin_start (12);
            grid.set_margin_end (12);
            grid.set_margin_top (6);
            grid.set_margin_bottom (6);
            grid.set_column_spacing (12);

            grid.add (check_button);
            grid.add (label);

            return grid;
        }
    }
}

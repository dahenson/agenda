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

    const int MIN_WIDTH = 500;
    const int MIN_HEIGHT = 600;

    const string HINT_STRING = _("Add a new task…");

    public class Window : Gtk.ApplicationWindow {

        private uint configure_id;

        private GLib.Settings privacy_setting = new GLib.Settings (
            "org.gnome.desktop.privacy");

        private Granite.Widgets.Welcome agenda_welcome;
        private Gtk.ScrolledWindow scrolled_window;
        private Gtk.Entry task_entry;
        private Agenda.TaskListBox task_list_box;

        public Window (Application app) {
            Object (application: app);

            var window_close_action = new SimpleAction ("close", null);
            var app_quit_action = new SimpleAction ("quit", null);
            var undo_action = new SimpleAction ("undo", null);
            var redo_action = new SimpleAction ("redo", null);

            add_action (window_close_action);
            add_action (app_quit_action);
            add_action (undo_action);
            add_action (redo_action);

            app.set_accels_for_action ("win.close", {"<Ctrl>W"});
            app.set_accels_for_action ("win.quit", {"<Ctrl>Q"});
            app.set_accels_for_action ("win.undo", {"<Ctrl>Z"});
            app.set_accels_for_action ("win.redo", {"<Ctrl>Y"});

            this.get_style_context ().add_class ("rounded");
            this.set_size_request (MIN_WIDTH, MIN_HEIGHT);

            var header = new Gtk.HeaderBar ();
            header.show_close_button = true;
            header.get_style_context ().add_class ("titlebar");
            header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            this.set_titlebar (header);

            // Set up geometry
            Gdk.Geometry geo = Gdk.Geometry ();
            geo.min_width = MIN_WIDTH;
            geo.min_height = MIN_HEIGHT;
            geo.max_width = 1024;
            geo.max_height = 2048;

            this.set_geometry_hints (
                null,
                geo,
                Gdk.WindowHints.MIN_SIZE | Gdk.WindowHints.MAX_SIZE);

            restore_window_position ();

            setup_ui ();

            window_close_action.activate.connect (this.close);
            app_quit_action.activate.connect (this.close);
            //undo_action.activate.connect (task_list.undo);
            //redo_action.activate.connect (task_list.redo);
        }

        private void setup_ui () {
            this.set_title ("Agenda");

            var first = Application.settings.get_boolean ("first-time");
            if (first) {
                Application.settings.set_boolean ("first-time", false);
            }

            agenda_welcome = new Granite.Widgets.Welcome (
                _("No Tasks!"),
                first ? _("(add one below)") : _("(way to go)"));
            agenda_welcome.expand = true;

            task_list_box = new Agenda.TaskListBox (Application.tasks);
            task_list_box.task_changed.connect (update_task);

            scrolled_window = new Gtk.ScrolledWindow (null, null);
            scrolled_window.expand = true;
            scrolled_window.set_policy (
                Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (task_list_box);

            task_entry = new Gtk.Entry ();
            task_entry.name = "TaskEntry";
            task_entry.get_style_context ().add_class ("task-entry");
            task_entry.placeholder_text = HINT_STRING;
            task_entry.max_length = 64;
            task_entry.hexpand = true;
            task_entry.valign = Gtk.Align.START;
            task_entry.set_icon_tooltip_text (
                Gtk.EntryIconPosition.SECONDARY, _("Add to list…"));

            task_entry.activate.connect (append_task);
            task_entry.icon_press.connect (append_task);

            task_entry.changed.connect (() => {
                var str = task_entry.get_text ();
                if ( str == "" ) {
                    task_entry.set_icon_from_icon_name (
                        Gtk.EntryIconPosition.SECONDARY, null);
                } else {
                    task_entry.set_icon_from_icon_name (
                        Gtk.EntryIconPosition.SECONDARY, "list-add-symbolic");
                }
            });

            this.key_press_event.connect (key_down_event);

            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.row_homogeneous = false;
            grid.attach (agenda_welcome, 0, 0, 1, 1);
            grid.attach (scrolled_window, 0, 1, 1, 1);
            grid.attach (task_entry, 0, 2, 1, 1);

            this.add (grid);

            task_entry.margin_start = 12;
            task_entry.margin_end = 12;
            task_entry.margin_top = 12;
            task_entry.margin_bottom = 12;

            task_entry.grab_focus ();
        }

        public void append_task () {
            Task task = new Task.with_attributes (
                "",
                false,
                task_entry.text);

            Application.tasks.add (task);

            task_entry.text = "";
        }

        public void update_task (int index, Task task) {
            Application.tasks.update (index, task);
        }

        public void restore_window_position () {
            var size = Application.settings.get_value ("window-size");
            var position = Application.settings.get_value ("window-position");

            if (position.n_children () == 2) {
                var x = (int) position.get_child_value (0);
                var y = (int) position.get_child_value (1);

                debug ("Moving window to coordinates %d, %d", x, y);
                move (x, y);
            } else {
                debug ("Moving window to the centre of the screen");
                window_position = Gtk.WindowPosition.CENTER;
            }

            if (size.n_children () == 2) {
                var rect = Gtk.Allocation ();
                rect.width = (int) size.get_child_value (0);
                rect.height = (int) size.get_child_value (1);

                debug ("Resizing to width and height: %d, %d", rect.width, rect.height);
                set_allocation (rect);
            } else {
                debug ("Not resizing window");
            }
        }

        public bool main_quit () {
            this.destroy ();

            return false;
        }

        public bool key_down_event (Gdk.EventKey e) {
            switch (e.keyval) {
                case Gdk.Key.Escape:
                    if (true) { //!task_view.is_editing) {
                        main_quit ();
                    }
                    break;
                case Gdk.Key.Delete:
                    if (!task_entry.has_focus) { // && !task_view.is_editing) {
                        // task_view.toggle_selected_task ();
                        update ();
                    }
                    break;
            }

            return false;
        }

        public void update () {
            if (Application.tasks.get_n_items () == 0)
                show_welcome ();
            else
                hide_welcome ();
        }

        void show_welcome () {
            scrolled_window.hide ();
            agenda_welcome.show ();
        }

        void hide_welcome () {
            agenda_welcome.hide ();
            scrolled_window.show ();
        }

        public override bool configure_event (Gdk.EventConfigure event) {
            if (configure_id != 0) {
                GLib.Source.remove (configure_id);
            }

            configure_id = Timeout.add (100, () => {
                configure_id = 0;

                int x, y;
                Gdk.Rectangle rect;

                get_position (out x, out y);
                get_allocation (out rect);

                debug ("Saving window position to %d, %d", x, y);
                Application.settings.set_value (
                    "window-position", new int[] { x, y });

                debug (
                    "Saving window size of width and height: %d, %d",
                    rect.width, rect.height);
                Application.settings.set_value (
                    "window-size", new int[] { rect.width, rect.height });

                return false;
            });

            return base.configure_event (event);
        }
    }
}

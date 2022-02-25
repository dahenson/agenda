/***

    Copyright (C) 2014-2022 Agenda Developers

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

    const string HINT_STRING = _("Add a new task…");

    public class Window : Gtk.ApplicationWindow {

        private uint configure_id;

        private GLib.Settings privacy_setting = new GLib.Settings (
            "org.gnome.desktop.privacy");

        private Gtk.Entry task_entry;
        private Gtk.Stack stack;

        public Window (Application app) {
            Object (application: app);

            setup_ui ();
            restore_window_position ();

            var close_action = new SimpleAction ("close", null);
            var quit_action = new SimpleAction ("quit", null);
            var undo_action = new SimpleAction ("undo", null);
            var redo_action = new SimpleAction ("redo", null);

            add_action (close_action);
            add_action (quit_action);
            add_action (undo_action);
            add_action (redo_action);

            app.set_accels_for_action ("win.close", {"<Ctrl>W"});
            app.set_accels_for_action ("win.quit", {"<Ctrl>Q"});
            app.set_accels_for_action ("win.undo", {"<Ctrl>Z"});
            app.set_accels_for_action ("win.redo", {"<Ctrl><Shift>Z"});

            close_action.activate.connect (this.close);
            quit_action.activate.connect (this.close);
            undo_action.activate.connect (this.undo);
            redo_action.activate.connect (this.redo);
        }

        private void setup_ui () {
            this.set_title ("Agenda");

            this.get_style_context ().add_class ("rounded");

            var header = new Gtk.HeaderBar ();
            header.show_close_button = true;
            header.get_style_context ().add_class ("titlebar");
            header.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            this.set_titlebar (header);

            var first = Application.settings.get_boolean ("first-time");
            if (first) {
                Application.settings.set_boolean ("first-time", false);
            }

            var agenda_welcome = new Granite.Widgets.Welcome (
                _("No Tasks!"), first ? _("(add one below)") : _("(way to go)")) {
                expand = true
            };

            var task_box = new Agenda.TaskBox (Application.tasks);

            var scrolled_window = new Gtk.ScrolledWindow (null, null) {
                expand = true,
                hscrollbar_policy = Gtk.PolicyType.NEVER,
                vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            };

            task_entry = new Gtk.Entry () {
                name = "TaskEntry",
                placeholder_text = HINT_STRING,
                max_length = 64,
                hexpand = true,
                valign = Gtk.Align.START,
                secondary_icon_tooltip_text = _("Add to list..."),
                margin_start = 12,
                margin_end = 12,
                margin_top = 12,
                margin_bottom = 12
            };

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                expand = true,
                homogeneous = false
            };

            stack = new Gtk.Stack () {
                homogeneous = true,
                transition_duration = 200,
                transition_type = Gtk.StackTransitionType.CROSSFADE
            };

            scrolled_window.add (task_box);

            stack.add_named (scrolled_window, "tasklist");
            stack.add_named (agenda_welcome, "welcome");

            box.add (stack);
            box.add (task_entry);

            this.add (box);

            task_entry.grab_focus ();

            task_box.update_task.connect ((index, task) => {
                Application.tasks.update (index, task);
            });

            task_box.remove_task.connect ((task) => {
                Application.tasks.remove (task);
                update_gui ();
            });

            this.key_press_event.connect (key_down_event);

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
        }

        public void append_task () {
            Task task = new Task.with_attributes (
                "",
                false,
                task_entry.text);

            Application.tasks.add (task);

            task_entry.text = "";
            update_gui ();
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
                        update_gui ();
                    }
                    break;
            }

            return false;
        }

        public void update_gui () {
            if (Application.tasks.get_n_items () == 0)
                stack.set_visible_child_name ("welcome");
            else
                stack.set_visible_child_name ("tasklist");
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

        private void redo () {
            Application.tasks.redo ();
            update_gui ();
        }

        private void undo () {
            Application.tasks.undo ();
            update_gui ();
        }
    }
}

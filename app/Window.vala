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

            var header = new Gtk.HeaderBar () {
                show_title_buttons = true
            };
            this.set_titlebar (header);

            var first = Application.settings.get_boolean ("first-time");
            if (first) {
                Application.settings.set_boolean ("first-time", false);
            }

            var agenda_welcome = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            /*var agenda_welcome = new Granite.Widgets.Welcome (
                _("No Tasks!"), first ? _("(add one below)") : _("(way to go)")) {
                expand = true
            };*/

            var list_box = new Gtk.ListBox ();
            list_box.bind_model (Application.tasks, list_box_create_widget);

            var scrolled_window = new Gtk.ScrolledWindow () {
                hexpand = true,
                vexpand = true,
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
                hexpand = true,
                vexpand = true,
                homogeneous = false
            };

            stack = new Gtk.Stack () {
                hhomogeneous = true,
                vhomogeneous = true,
                transition_duration = 200,
                transition_type = Gtk.StackTransitionType.CROSSFADE
            };

            scrolled_window.set_child (list_box);

            stack.add_named (scrolled_window, "tasklist");
            stack.add_named (agenda_welcome, "welcome");

            box.append (stack);
            box.append (task_entry);

            this.set_child (box);

            task_entry.grab_focus ();

            var key_events = new Gtk.EventControllerKey ();
            key_events.key_pressed.connect (key_down_event);
            ((Gtk.Widget) this).add_controller (key_events);

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
                //move (x, y);
            } else {
                debug ("Moving window to the centre of the screen");
                //window_position = Gtk.WindowPosition.CENTER;
            }

            if (size.n_children () == 2) {
                var width = (int) size.get_child_value (0);
                var height = (int) size.get_child_value (1);

                debug ("Resizing to width and height: %d, %d", width, height);
                set_default_size (width, height);
            } else {
                debug ("Not resizing window");
            }
        }

        public bool main_quit () {
            this.destroy ();

            return false;
        }

        public void update_gui () {
            if (Application.tasks.get_n_items () == 0)
                stack.set_visible_child_name ("welcome");
            else
                stack.set_visible_child_name ("tasklist");
        }

        /*
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
        */

        private bool key_down_event (uint keyval, uint keycode, Gdk.ModifierType state) {
            switch (keyval) {
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
                Application.tasks.remove (task);
                update_gui ();
            });

            check_button.toggled.connect (() => {
                task.complete = check_button.active;

                strike_attr = Pango.attr_strikethrough_new (task.complete);
                attr_list.insert ((owned) strike_attr);
                label.set_attributes (attr_list);

                var index = row.get_index ();
                Application.tasks.update (index, task);
            });

            return row;
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

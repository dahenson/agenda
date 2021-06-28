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

    public class AgendaWindow : Gtk.ApplicationWindow {

        private GLib.Settings agenda_settings = new GLib.Settings (
            "com.github.dahenson.agenda");
        private GLib.Settings privacy_setting = new GLib.Settings (
            "org.gnome.desktop.privacy");

        private FileBackend backend;

        private Granite.Widgets.Welcome agenda_welcome;
        private TaskView task_view;
        private TaskList task_list;
        private Gtk.ScrolledWindow scrolled_window;
        private Gtk.Entry task_entry;
        private HistoryList history_list;

        public AgendaWindow (Agenda app) {
            Object (application: app);

            var undo_action = new SimpleAction ("undo-action", null);
            var redo_action = new SimpleAction ("redo-action", null);

            add_action (undo_action);
            add_action (redo_action);

            app.set_accels_for_action ("win.undo-action",
                                       {"<Ctrl>Z"});
            app.set_accels_for_action ("win.redo-action",
                                       {"<Ctrl>Y"});

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

            var first = agenda_settings.get_boolean ("first-time");
            agenda_welcome = new Granite.Widgets.Welcome (
                _("No Tasks!"),
                first ? _("(add one below)") : _("(way to go)"));
            task_list = new TaskList ();
            task_view = new TaskView.with_list (task_list);
            scrolled_window = new Gtk.ScrolledWindow (null, null);
            task_entry = new Gtk.Entry ();

            history_list = new HistoryList ();

            if (first) {
                agenda_settings.set_boolean ("first-time", false);
            }

            backend = new FileBackend ();

            load_list ();
            setup_ui ();

            undo_action.activate.connect (task_list.undo);
            redo_action.activate.connect (task_list.redo);
        }

        private void load_list () {
            task_list.disable_undo_recording ();

            var tasks = backend.load_tasks ();
            foreach (Task task in tasks) {
                task_list.append_task (task);
            }

            var history = backend.load_history ();
            if (privacy_mode_off ()) {
                foreach (string line in history) {
                    history_list.add_item (line);
                }
            }

            task_list.enable_undo_recording ();
            task_list.clear_undo ();
        }

        private void setup_ui () {
            this.set_title ("Agenda");

            task_entry.name = "TaskEntry";
            task_entry.get_style_context ().add_class ("task-entry");
            task_entry.placeholder_text = HINT_STRING;
            task_entry.max_length = 64;
            task_entry.hexpand = true;
            task_entry.valign = Gtk.Align.START;
            task_entry.set_icon_tooltip_text (
                Gtk.EntryIconPosition.SECONDARY, _("Add to list…"));

            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();
            completion.set_model (history_list);
            completion.set_text_column (0);

            task_entry.set_completion (completion);

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

            task_entry.populate_popup.connect ((menu) => {
                Gtk.TreeIter iter;
                bool valid = history_list.get_iter_first (out iter);
                var separator = new Gtk.SeparatorMenuItem ();
                var item_clear_history = new Gtk.MenuItem.with_label (_("Clear history"));

                menu.insert (separator, 6);
                menu.insert (item_clear_history, 7);

                item_clear_history.activate.connect (() => {
                    history_list.clear ();
                });

                if (valid) {
                    item_clear_history.set_sensitive (true);
                } else {
                    item_clear_history.set_sensitive (false);
                }

                menu.show_all ();
            });

            task_view.focus_out_event.connect ((e) => {
                Gtk.TreeSelection selected;
                selected = task_view.get_selection ();
                selected.unselect_all ();
                return false;
            });

            task_list.list_changed.connect (() => {
                backend.save_tasks (task_list.get_all_tasks ());
                update ();
            });

            this.key_press_event.connect (key_down_event);

            task_view.expand = true;
            scrolled_window.expand = true;
            scrolled_window.set_policy (
                Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (task_view);

            agenda_welcome.expand = true;

            var grid = new Gtk.Grid ();
            grid.expand = true;
            grid.row_homogeneous = false;
            grid.attach (agenda_welcome, 0, 0, 1, 1);
            grid.attach (scrolled_window, 0, 1, 1, 1);
            grid.attach (task_entry, 0, 2, 1, 1);

            this.add (grid);

            task_entry.margin_start = 10;
            task_entry.margin_end = 10;
            task_entry.margin_top = 10;
            task_entry.margin_bottom = 10;

            task_entry.grab_focus ();
        }

        public void append_task () {
            Task task = new Task.with_attributes (
                "",
                false,
                task_entry.text);

            task_list.append_task (task);
            history_list.add_item (task.text);
            task_entry.text = "";
        }

        public bool privacy_mode_off () {
            bool remember_app_usage = privacy_setting.get_boolean ("remember-app-usage");
            bool remember_recent_files = privacy_setting.get_boolean ("remember-recent-files");

            return remember_app_usage || remember_recent_files;
        }

        public void restore_window_position () {
            var position = agenda_settings.get_value ("window-position");
            var win_size = agenda_settings.get_value ("window-size");

            if (position.n_children () == 2) {
                var x = (int32) position.get_child_value (0);
                var y = (int32) position.get_child_value (1);

                debug ("Moving window to coordinates %d, %d", x, y);
                this.move (x, y);
            } else {
                debug ("Moving window to the centre of the screen");
                this.window_position = Gtk.WindowPosition.CENTER;
            }

            if (win_size.n_children () == 2) {
                var width = (int32) win_size.get_child_value (0);
                var height = (int32) win_size.get_child_value (1);
                debug ("Resizing to width and height: %d, %d", width, height);
                this.resize (width, height);
            } else {
                debug ("Not resizing window");
            }
        }

        public void save_window_position () {
            int x, y, width, height;
            this.get_position (out x, out y);
            this.get_size (out width, out height);
            debug ("Saving window position to %d, %d", x, y);
            agenda_settings.set_value ("window-position", new int[] { x, y });
            debug ("Saving window size of width and height: %d, %d", width, height);
            agenda_settings.set_value ("window-size", new int[] { width, height });
        }

        public bool main_quit () {
            backend.save_tasks (task_list.get_all_tasks ());
            backend.save_history (history_list.get_all_tasks ());
            save_window_position ();
            this.destroy ();

            return false;
        }

        public bool key_down_event (Gdk.EventKey e) {
            switch (e.keyval) {
                case Gdk.Key.Escape:
                    if (!task_view.is_editing) {
                        main_quit ();
                    }
                    break;
                case Gdk.Key.Delete:
                    if (!task_entry.has_focus && !task_view.is_editing) {
                        task_view.toggle_selected_task ();
                        update ();
                    }
                    break;
            }

            return false;
        }

        public void update () {
            if ( task_list.is_empty () )
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
    }
}

/***

    Copyright (C) 2014-2018 Agenda Developers

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

    const string HINT_STRING = _("Add a new task...");

    public class AgendaWindow : Gtk.Window {

        private GLib.Settings agenda_settings = new GLib.Settings (
            "com.github.dahenson.agenda");
        private GLib.Settings privacy_setting = new GLib.Settings (
            "org.gnome.desktop.privacy");

        File list_file;
        File history_file;

        private Granite.Widgets.Welcome agenda_welcome;
        private TaskView                task_view;
        private TaskList                task_list;
        private Gtk.ScrolledWindow      scrolled_window;
        private Gtk.Entry               task_entry;
        private Gtk.Grid                grid;
        private HistoryList             history_list;
        private Gtk.SeparatorMenuItem   separator;
        private Gtk.MenuItem            item_clear_history;
        private bool                    is_editing;

        public AgendaWindow () {
            this.get_style_context ().add_class ("rounded");
            this.set_size_request(MIN_WIDTH, MIN_HEIGHT);

            // Set up geometry
            Gdk.Geometry geo = Gdk.Geometry();
            geo.min_width = MIN_WIDTH;
            geo.min_height = MIN_HEIGHT;
            geo.max_width = 1024;
            geo.max_height = 2048;

            this.set_geometry_hints(
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
            grid = new Gtk.Grid ();

            history_list = new HistoryList ();

            is_editing = false;

            load_list ();
            setup_ui ();
        }

        private void load_list () {
            Granite.Services.Paths.initialize (
                "agenda", Build.PKGDATADIR);
            Granite.Services.Paths.ensure_directory_exists (
                Granite.Services.Paths.user_data_folder);

            list_file = Granite.Services.Paths.user_data_folder.get_child ("tasks");
            history_file = Granite.Services.Paths.user_data_folder.get_child ("history");

            if ( !list_file.query_exists () ) {
                try {
                    list_file.create (FileCreateFlags.NONE);
                } catch (Error e) {
                    error ("Error: %s\n", e.message);
                }
            }

            if ( !history_file.query_exists () ) {
                try {
                    history_file.create (FileCreateFlags.NONE);
                } catch (Error e) {
                    error ("Error: %s\n", e.message);
                }
            }

            try {
                string line;
                var f_dis = new DataInputStream (list_file.read ());

                while ((line = f_dis.read_line (null)) != null) {
                    var task = line.split (",", 2);
                    if (task[0] == "t") {
                        task_list.append_task (task[1], true);
                    } else {
                        task_list.append_task (task[1], false);
                    }
                }

                var h_dis = new DataInputStream (history_file.read ());
                while ((line = h_dis.read_line (null)) != null && privacy_mode_off ()) {
                    history_list.add_item (line);
                }
            } catch (Error e) {
                error ("%s", e.message);
            }
        }

        private void setup_ui () {
            this.set_title ("Agenda");

            task_entry.name = "TaskEntry";
            task_entry.get_style_context().add_class("task-entry");
            task_entry.placeholder_text = HINT_STRING;
            task_entry.max_length = 64;
            task_entry.hexpand = true;
            task_entry.valign = Gtk.Align.START;
            task_entry.set_icon_tooltip_text (
                Gtk.EntryIconPosition.SECONDARY, _("Add to list..."));

            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();
            completion.set_model (history_list);
            completion.set_text_column (0);

            task_entry.set_completion (completion);

            task_entry.activate.connect (append_task);
            task_entry.icon_press.connect (append_task);

            task_entry.changed.connect(() => {
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
                separator = new Gtk.SeparatorMenuItem ();
                item_clear_history = new Gtk.MenuItem.with_label (_("Clear history"));

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

            task_view.list_changed.connect (() => {
                /**
                 *  When a row is dragged and dropped, a new row is inserted,
                 *  then populated, then the old row is deleted.  This way, we
                 *  write the new order to the file every time it gets reordered
                 *  through DND.  This also takes care of the toggled row, since
                 *  it is removed and the row_deleted signal is emitted.
                 */
                save_list (task_list.get_all_tasks(), list_file);
                update ();
            });

            this.key_press_event.connect (key_down_event);

            task_view.expand = true;
            scrolled_window.expand = true;
            scrolled_window.set_policy (
                Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (task_view);

            agenda_welcome.expand = true;

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
            var text = task_entry.text;
            task_list.append_task (text, false);
            history_list.add_item (text);
            task_entry.text = "";
            update ();
        }

        public bool privacy_mode_off () {
            return privacy_setting.get_boolean ("remember-app-usage") || privacy_setting.get_boolean ("remember-recent-files");
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
                var width =  (int32) win_size.get_child_value (0);
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
            save_list (task_list.get_all_tasks(), list_file);
            history_to_file ();
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

        public void history_to_file () {
            Gtk.TreeIter iter;
            bool valid = history_list.get_iter_first (out iter);

            try {
                if (history_file.query_exists ()) {
                    history_file.delete ();
                }

                var history_dos = new DataOutputStream (
                    history_file.create (FileCreateFlags.REPLACE_DESTINATION));
                while (valid) {
                    string text;

                    history_list.get (iter, 0, out text);
                    history_dos.put_string (text + "\n");
                    valid = history_list.iter_next (ref iter);
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }
    }
}

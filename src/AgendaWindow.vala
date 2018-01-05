/***

    Copyright (C) 2014-2016 Agenda Developers

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses>

***/

namespace Agenda {

    const int MIN_WIDTH = 500;
    const int MIN_HEIGHT = 600;

    const string HINT_STRING = _("Add a new task...");

    public class AgendaWindow : Gtk.Window {

        private GLib.Settings agenda_settings = new GLib.Settings ("com.github.dahenson.agenda");
        private GLib.Settings privacy_setting = new GLib.Settings ("org.gnome.desktop.privacy");

        File list_file;
        File history_file;

        /* GUI components */
        private Granite.Widgets.Welcome agenda_welcome;     // The Welcome screen when there are no tasks
        private TaskList                task_list;          // Stores tasks for accessing by a TreeView
        private Gtk.ScrolledWindow      scrolled_window;    // Container for the treeview
        private Gtk.Entry               task_entry;         // Entry that accepts tasks
        private Gtk.Grid                grid;               // Container for everything
        private Gtk.ListStore           history_list;       // List where history of tasks is stored
        private Gtk.SeparatorMenuItem   separator;
        private Gtk.MenuItem            item_clear_history;
        private bool                    is_editing;         // Whether a task is being edited

        public AgendaWindow () {
            this.get_style_context ().add_class ("rounded");

            this.set_size_request(MIN_WIDTH, MIN_HEIGHT);

            // Set up geometry
            Gdk.Geometry geo = Gdk.Geometry();
            geo.min_width = MIN_WIDTH;
            geo.min_height = MIN_HEIGHT;
            geo.max_width = 1024;
            geo.max_height = 2048;

            this.set_geometry_hints(null, geo, Gdk.WindowHints.MIN_SIZE | Gdk.WindowHints.MAX_SIZE);

            restore_window_position ();

            var first = agenda_settings.get_boolean ("first-time");

            /**
             *  Initialize the GUI components
             */
            agenda_welcome = new Granite.Widgets.Welcome (_("No Tasks!"), 
                                                           first ? _("(add one below)") : _("(way to go)"));
            task_list = new TaskList ();
            scrolled_window = new Gtk.ScrolledWindow (null, null);
            task_entry = new Gtk.Entry ();
            grid = new Gtk.Grid ();

            history_list = new Gtk.ListStore (1, typeof (string));

            is_editing = false;

            load_list ();   // Load the list from file
            setup_ui ();    // Set up the GUI
        }

        /**
         *  Loads the list from a file, or creates a new list if one doesn't exist.
         */
        private void load_list () {

            Granite.Services.Paths.initialize ("agenda", Build.PKGDATADIR); // initialize directory paths for agenda
            Granite.Services.Paths.ensure_directory_exists (Granite.Services.Paths.user_data_folder); // make sure the user specific agenda data directory exists

            list_file = Granite.Services.Paths.user_data_folder.get_child ("tasks");
            history_file = Granite.Services.Paths.user_data_folder.get_child ("history");

            // If the file doesn't exist, try to create it
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

                // Open list_file for reading
                var f_dis = new DataInputStream (list_file.read ());
                // Read lines until end of file (null) is reached
                while ((line = f_dis.read_line (null)) != null) {
                    var task = line.split (",", 2);
                    if (task[0] == "t") {
                        task_list.append_task (task[1], true);
                    } else {
                        task_list.append_task (task[1], false);
                    }
                }

                // Create history list
                var h_dis = new DataInputStream (history_file.read ());
                while ((line = h_dis.read_line (null)) != null && privacy_mode_off ()) {
                    add_to_history (line);
                }
            } catch (Error e) {
                error ("%s", e.message);
            }
        }

        /**
         * Builds all of the widgets and arranges them in the window.
         */
        private void setup_ui () {
            this.set_title ("Agenda");

            // Set up the task entry
            task_entry.name = "TaskEntry";
            task_entry.get_style_context().add_class("task-entry");
            task_entry.placeholder_text = HINT_STRING;
            task_entry.max_length = 64;
            task_entry.hexpand = true;
            task_entry.valign = Gtk.Align.START;
            task_entry.set_icon_tooltip_text (Gtk.EntryIconPosition.SECONDARY, _("Add to list..."));

            // The EntryCompletion
            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();
            task_entry.set_completion (completion);

            // Create, fill & register a ListStore
            completion.set_model (history_list);
            completion.set_text_column (0);

            // Method for when the task entry is activated
            task_entry.activate.connect (append_task);
            task_entry.icon_press.connect (append_task);

            // Control the appearance of the symbolic add icon in task_entry
            task_entry.changed.connect(() => {
                var str = task_entry.get_text ();
                if ( str == "" ) {
                    task_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
                } else {
                    task_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "list-add-symbolic");
                }
            });

            // Add option to clear history list in context menu
            task_entry.populate_popup.connect ((menu) => {
                Gtk.TreeIter iter;
                bool valid = history_list.get_iter_first (out iter);
                separator = new Gtk.SeparatorMenuItem ();
                item_clear_history = new Gtk.MenuItem.with_label (_("Clear history"));

                menu.insert (separator, 6);
                menu.insert (item_clear_history, 7);

                // Clear history list
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

            /**
             *  Unselect everything when not focused on the treeview.
             */
            task_list.focus_out_event.connect ((e) => {
                Gtk.TreeSelection selected;
                selected = task_list.get_selection ();
                selected.unselect_all ();
                return false;
            });

            // Method for when a row is removed from the task_list or the list is reordered
            task_list.list_changed.connect (() => {
                /**
                 *  When a row is dragged and dropped, a new row is inserted,
                 *  then populated, then the old row is deleted.  This way, we
                 *  write the new order to the file every time it gets reordered
                 *  through DND.  This also takes care of the toggled row, since
                 *  it is removed and the row_deleted signal is emitted.
                 */
                tasks_to_file ();
                update ();
            });

            this.key_press_event.connect (key_down_event);

            /**
             *  Set up the scrolled window and add tree_view
             */
            task_list.expand = true;
            scrolled_window.expand = true;
            scrolled_window.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (task_list);

            agenda_welcome.expand = true;

            grid.expand = true;   // expand the box to fill the whole window
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
                task_list.append_task (task_entry.text, false);
                task_entry.text = "";
                update ();
            }

        /**
         *  Check if the system is in Privacy mode.
         */
        public bool privacy_mode_off () {
            return privacy_setting.get_boolean ("remember-app-usage") || privacy_setting.get_boolean ("remember-recent-files");
        }

        /**
         *  Restore window position.
         */
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

        /**
         *  Save window position.
         */
        public void save_window_position () {
            int x, y, width, height;
            this.get_position (out x, out y);
            this.get_size (out width, out height);
            debug ("Saving window position to %d, %d", x, y);
            agenda_settings.set_value ("window-position", new int[] { x, y });
            debug ("Saving window size of width and height: %d, %d", width, height); 
            agenda_settings.set_value ("window-size", new int[] { width, height });
        }

        /**
         *  Quit from the program.
         */
        public bool main_quit () {
            tasks_to_file ();
            history_to_file ();
            save_window_position ();
            this.destroy ();

            return false;
        }

        /**
         *  Key Press Events
         */
        public bool key_down_event (Gdk.EventKey e) {
            switch (e.keyval) {
                case Gdk.Key.Escape:
                    if (!task_list.is_editing) {
                        main_quit ();
                    }
                    break;
                case Gdk.Key.Delete:
                    if (!task_entry.has_focus && !task_list.is_editing) {
                        task_list.toggle_selected_task ();
                        update ();
                    }
                    break;
            }

            return false;
        }

        /**
         *  Add task to history list.
         */
        private void add_to_history (string text) {
            Gtk.TreeIter iter;
            string row;
            bool valid = history_list.get_iter_first (out iter);

            if (valid == false) {
                history_list.append (out iter);
                history_list.set (iter, 0, text);
            } else {
                while (valid) {
                    history_list.get (iter, 0, out row);
                    if (row == text) {
#if VALA_0_36
                        history_list.remove (ref iter);
#else
                        history_list.remove (iter);
#endif
                    }

                    valid = history_list.iter_next (ref iter);
                }

                history_list.append (out iter);
                history_list.set (iter, 0, text);
            }
        }

        /**
         *  Updates the window to show the welcome screen if the list is empty.
         */
        public void update () {
            if ( !task_list.is_empty () )
                show_welcome ();
            else
                hide_welcome ();
        }

        /**
         *  Hides the scrolled_window (task list) and shows the Welcome screen.
         */
        void show_welcome () {
            scrolled_window.hide ();
            agenda_welcome.show ();
        }

        /**
         *  Hides the Welcome screen and shows the scrolled_window (task list).
         */
        void hide_welcome () {
            agenda_welcome.hide ();
            scrolled_window.show ();
        }

        /**
         *  Writes the list to a file.
         */
        public void tasks_to_file () {
            try {
                if (list_file.query_exists ()) {    // delete the file if it already exists
                    list_file.delete ();
                }

                var file_dos = new DataOutputStream (list_file.create (FileCreateFlags.REPLACE_DESTINATION));
                var tasks = task_list.get_all_tasks ();
                foreach (string task in tasks) {
                    file_dos.put_string (task + "\n");
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }

        public void history_to_file () {
            Gtk.TreeIter iter;
            bool valid = history_list.get_iter_first (out iter);

            try {
                if (history_file.query_exists ()) {
                    history_file.delete ();
                }

                var history_dos = new DataOutputStream (history_file.create (FileCreateFlags.REPLACE_DESTINATION));
                while (valid) {
                    string text;

                    history_list.get (iter, 0, out text);
                    history_dos.put_string (text + "\n");       // write line to file here
                    valid = history_list.iter_next (ref iter);
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }
    }
}

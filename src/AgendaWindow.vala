/***
  BEGIN LICENSE

  Copyright (C) 2011-2012 Dane Henson <dane.henson@gmail.com>

  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as
  published    by the Free Software Foundation.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program.  If not, see <http://www.gnu.org/licenses>

  END LICENSE
***/

namespace Agenda {
    
    /**
     *  The dimensions now are greater than when it was a LightWindow
     *  becouse sizing for dialogs is different and these new measures
     *  make it possible to have a window as big as the previous one.
     */
    const int MIN_WIDTH = 440;
    const int MIN_HEIGHT = 520;
    const string HINT_STRING = _("Add a new task...");

    public class AgendaWindow : Gtk.Dialog {

        private Settings settings = new Settings ("net.launchpad.agenda-tasks");

        private enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DRAGHANDLE,
            N_COLUMNS
        }

        File list_file;
        
        private const string STYLE = """

            GraniteWidgetsWelcome {
                background-color: shade (#FFF, 0.96);
            }

            GtkTreeView row {
                background-color: shade (#FFF, 0.96);
                color: #333;
            }

            .cell:selected,
            .cell:selected:focus {
                background-color: @selected_bg_color;
                color: @selected_fg_color;
            }

        """;

        /**
         *  These are the GUI components
         */
        private Granite.Widgets.Welcome     agenda_welcome; // The Welcome screen when there are no tasks
        private Gtk.ListStore               task_list;      // Stores tasks for accessing by a TreeView
        private Gtk.TreeView                tree_view;      // TreeView to display tasks
        private Gtk.ScrolledWindow          scrolled_window;// Container for the treeview
        private Gtk.Entry                   task_entry;     // Entry that accepts tasks
        private Gtk.Grid                    grid;           // Container for everything

        /**
         *  AgendaWindow Constructor
         */
        public AgendaWindow () {

            Object (use_header_bar: 1);
            title = "Agenda";      // Set the window title
            resizable = false;     // Window is not resizable
            set_keep_above (true); // Window stays on top of other windows
            type_hint = Gdk.WindowTypeHint.NORMAL;      // restore normal open/close animation
            set_size_request (MIN_WIDTH, MIN_HEIGHT);   // set minimum window size

            get_header_bar ().get_style_context ().remove_class ("header-bar");

            var css_provider = load_css ();
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default(),
                                                      css_provider,
                                                      Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            restore_window_position ();

            var first = settings.get_boolean ("first-time");

            /*
             *  Initialize the GUI components
             */
            agenda_welcome  = new Granite.Widgets.Welcome (_("No Tasks!"), 
                                                           first ? _("(add one below)") : _("(way to go)"));
            task_list       = new Gtk.ListStore (
                                                    Columns.N_COLUMNS,
                                                    typeof(bool),
                                                    typeof(string),
                                                    typeof(bool),
                                                    typeof(string)
                                                );
            scrolled_window = new Gtk.ScrolledWindow (null, null);
            task_entry      = new Gtk.Entry ();
            grid            = new Gtk.Grid ();
            tree_view       = new Gtk.TreeView ();
            
            
            load_list ();   // Load the list from file
            setup_ui ();    // Set up the GUI
            
            /*
             *  Allow moving the window
             */
            this.button_press_event.connect ( (e) => {
                if (e.button == 1) {
                    this.begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                    return true;
                }
                return false;
            });
            
        }
        
        /*
         *  Loads the list from a file, or creates a new list if one doesn't exist.
         */
        void load_list () {
            
            Granite.Services.Paths.initialize ("agenda", Build.PKGDATADIR);     // initialize directory paths for agenda
            Granite.Services.Paths.ensure_directory_exists (Granite.Services.Paths.user_data_folder);     // make sure the user specific agenda data directory exists
            
            list_file = Granite.Services.Paths.user_data_folder.get_child ("tasks");
            
            if ( !list_file.query_exists () ) {                 // If the file doesn't exist, try to create it
                try {
                    list_file.create (FileCreateFlags.NONE);
                } catch (Error e) {
                    error ("Error: %s\n", e.message);
                }
            }
            
            try {
                // Open list_file for reading
                var dis = new DataInputStream (list_file.read ());
                string line;
                // Read lines until end of file (null) is reached
                while ((line = dis.read_line (null)) != null) {
                    add_task (line);
                }
            } catch (Error e) {
                error ("%s", e.message);
            }
            
        }

        /**
         *  Builds all of the widgets and arranges them in the window.
         */
        void setup_ui () {

            /*
             *  Set up tree_view
             */
            tree_view.name              = "TaskList";
            tree_view.headers_visible   = false;            // disable headers
            tree_view.enable_search     = false;            // disable live search
            tree_view.hexpand           = true;             // make it fill the container
            tree_view.valign            = Gtk.Align.START;  // Align at the beginning of the parent container
            tree_view.reorderable       = true;             // make it reorderable (drag and drop)
            
            /*
             *   Set up the TreeView with the necessary columns
             */
            var column      = new Gtk.TreeViewColumn ();        // Used for generating Columns
            var text        = new Gtk.CellRendererText ();      // CellRendererText to display the task description
            var toggle      = new Gtk.CellRendererToggle ();    // CellRendererToggle for checking it off the list
            var draghandle  = new Gtk.CellRendererPixbuf ();    // CellRendererPixbuf to draw a pretty icon to make reordering easier
            
            // setup the TOGGLE column
            toggle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Toggle", toggle, "active", Columns.TOGGLE);
            tree_view.append_column (column);

            // setup the TEXT column
            text.ypad = 6;                              // set vertical padding between rows
            text.editable = true;
            text.max_width_chars = 10;
            text.ellipsize_set = true;
            text.ellipsize = Pango.EllipsizeMode.END;
            
            column = new Gtk.TreeViewColumn.with_attributes ("Task", text, "text", Columns.TEXT, "strikethrough", Columns.STRIKETHROUGH);
            column.expand = true;                       // the text column should fill the whole width of the column
            tree_view.append_column (column);
            
            // setup the DRAGHANDLE column
            draghandle.xpad = 6;
            column = new Gtk.TreeViewColumn.with_attributes ("Drag", draghandle, "icon_name", Columns.DRAGHANDLE);
            tree_view.append_column (column);
            tree_view.model = task_list;

            tree_view.set_tooltip_column (Columns.TEXT);

            /*
             *  Set up the task entry
             */
            task_entry.name                 = "TaskEntry";          // Name
            task_entry.placeholder_text     = HINT_STRING;
            task_entry.max_length           = 50;                   // Maximum character length
            task_entry.hexpand              = true;                 // Horizontally Expand
            task_entry.valign               = Gtk.Align.END;        // Align at the bottom of the parent container
            task_entry.secondary_icon_name  = "list-add-symbolic";  // Add the 'plus' icon on the right side of the entry


            // Method for when the task entry is activated
            task_entry.activate.connect (() => { add_task ( task_entry.text ); });
            task_entry.icon_press.connect ( () => { add_task (task_entry.text ); });

            // Method for editing tasks
            text.edited.connect ( (path, edited_text) => {
                /* If the user accidentally blanks a task, abort the edit */
                if (edited_text == "") {
                    return;
                }

                Gtk.TreeIter iter;
                task_list.get_iter (out iter, new Gtk.TreePath.from_string (path));
                task_list.set (iter, 1, edited_text);
                list_to_file ();
            });

            // Method for when a task is toggled (completed)
            toggle.toggled.connect ((toggle, path) => {
                var tree_path = new Gtk.TreePath.from_string (path);
                Gtk.TreeIter iter;
                task_list.get_iter (out iter, tree_path);
                task_list.set (iter, Columns.TOGGLE, !toggle.active, Columns.STRIKETHROUGH, !toggle.active);
            });

            /**
             *  Unselect everything when not focused on the treeview.
             */
            tree_view.focus_out_event.connect ((e) => {
                Gtk.TreeSelection selected;
                selected = tree_view.get_selection ();
                selected.unselect_all ();
                return false;
            });
            
            // Method for when a row is removed from the task_list or the list is reordered
            task_list.row_deleted.connect ((path, iter) => {
                /**
                 *  When a row is dragged and dropped, a new row is inserted,
                 *  then populated, then the old row is deleted.  This way, we
                 *  write the new order to the file every time it gets reordered
                 *  through DND.  This also takes care of the toggled row, since
                 *  it is removed and the row_deleted signal is emitted.
                 */
                list_to_file ();
            });
            
            this.key_press_event.connect (key_down_event);
            
            /**
             *  Set up the scrolled window and add tree_view
             */
            scrolled_window.expand = true;
            scrolled_window.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.add (tree_view);
            
            agenda_welcome.expand = true;
            
            grid.expand = true;      // expand the box to fill the whole window
            grid.row_homogeneous = false;
            grid.attach (agenda_welcome, 0, 0, 1, 1);
            grid.attach (scrolled_window, 0, 1, 1, 1);
            grid.attach (task_entry, 0, 2, 1, 1);
            
            ((Gtk.Container) get_content_area ()).add (grid);
            
            task_entry.margin_left = 10;
            task_entry.margin_right = 10;

            // OPINION: It's better not to put focus on startup because in this way user can see the hint
            //task_entry.grab_focus ();
        }

        public Gtk.CssProvider load_css () {
            var provider = new Gtk.CssProvider ();
            try {
                provider.load_from_data (STYLE, STYLE.length);
            } catch (Error e) {
                warning ("loading css: %s", e.message);
            }     
  
            return provider;
        }

        /**
         *  Restore window position.
         */
        public void restore_window_position () {
            var position = settings.get_value ("window-position");

            if (position.n_children () == 2) {
                var x = (int32) position.get_child_value (0);
                var y = (int32) position.get_child_value (1);
                
                debug ("Moving window to coordinates %d, %d", x, y);
                this.move (x, y);
            } else {
                debug ("Moving window to the centre of the screen");
                this.window_position = Gtk.WindowPosition.CENTER;
            }
        }

        /**
         *  Save window position.
         */
        public void save_window_position () {
            int x, y;   // Coordinates 
            this.get_position (out x, out y);
            debug ("Saving window position to %d, %d", x, y);
            settings.set_value ("window-position", new int[] { x, y });
        }

        /**
         *  Delete striketrough items.
         */
        public void delete_finished_tasks () {
            /*
             * Iterate through the task list and remove "active",
             * or checked off, entries.
             */
            Gtk.TreeIter iter;
            bool valid  = task_list.get_iter_first (out iter);
            bool active;
            int counter = 0;

            while (valid) { 
                task_list.get (iter, Columns.TOGGLE, out active);

                if (active) {
                    task_list.remove (iter);
                    valid = task_list.get_iter_first (out iter);
                    counter++;
                } else {
                    valid = task_list.iter_next (ref iter);
                }    
            }

            if (counter != 0)
                show_notification (_("Task finished"), counter > 1 ? counter.to_string () + _(" tasks have been removed") : _("A task has been removed"));
        }

        /**
         *  Quit from the program.
         */
        public bool main_quit () {
            delete_finished_tasks ();
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
                    main_quit ();
                    break;
                case Gdk.Key.Delete:
                    if (!task_entry.has_focus) {
                        Gtk.TreeIter iter;
                        Gtk.TreeSelection tree_selection;
                        bool current_state;
                        
                        tree_selection = tree_view.get_selection ();
                        tree_selection.get_selected (null, out iter);
                        task_list.get (iter, 0, out current_state);
                        
                        task_list.set (iter, Columns.TOGGLE, !current_state, Columns.STRIKETHROUGH, !current_state);   
                        update ();
                    }
                    break;
            }
            return false;
        }

        /**
         *  Add a task to the list.
         *
         *  @param task the task to be added to the list
         */
        void add_task (string task) {
            if (task == "") {    // if a task_entry is empty, don't add the task
                return;
            }
            
            Gtk.TreeIter iter;
            task_list.append (out iter);
            task_list.set (iter, Columns.TOGGLE, false, Columns.TEXT, task, Columns.STRIKETHROUGH, false, Columns.DRAGHANDLE, "view-list-symbolic");
            update ();
            list_to_file ();
            task_entry.set_text("");        // clear the entry box
            settings.set_boolean ("first-time", false);
        }
        
        /**
         *  Updates the window to show the welcome screen if the list is empty.
         */
        public void update () {
            Gtk.TreeIter iter;
            
            // get_iter_first returns false if there are no items in the list
            if ( !task_list.get_iter_first (out iter) )
                show_welcome ();
            else
                hide_welcome ();
        }
        
        /**
         *  Hides the scrolled_window (task list) and shows the Welcome screen
         */
        void show_welcome () {
            scrolled_window.hide ();
            agenda_welcome.show ();
        }
        
        /**
         *  Hides the Welcome screen and shows the scrolled_window (task list)
         */
        void hide_welcome () {
            agenda_welcome.hide ();
            scrolled_window.show ();
        }
        
        /**
         *  Writes the list to a file.
         */
        public void list_to_file () {
        
            Gtk.TreeIter iter;
            bool valid = task_list.get_iter_first (out iter);
            
            try {
                
                if (list_file.query_exists ()) {    // delete the file if it already exists
                    list_file.delete ();
                }
                
                var dos = new DataOutputStream (list_file.create (FileCreateFlags.REPLACE_DESTINATION));
                while (valid) {
                
                    string text;
                
                    task_list.get (iter, Columns.TEXT, out text);
                    dos.put_string (text + "\n");        // write line to file here
                    valid = task_list.iter_next (ref iter);
                    
                }
            } catch (Error e) {
                error ("Error: %s\n", e.message);
            }
        }
    }
}

using Gtk;
using Granite;
using Granite.Widgets;
using Granite.Services;

namespace Agenda {
    
    const int MIN_WIDTH = 350;
    const int MIN_HEIGHT = 430;
    const string HINT_STRING = N_("Add a new task...");

    public class AgendaWindow : Granite.Widgets.LightWindow {
    
        public static Granite.Application app { get; private set; }

        private enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DRAGHANDLE,
            N_COLUMNS
        }
        
        private State state = new State();  // The last state of the program (currently just width and height)
        
        Paths paths;
        File list_file;
        
        /*
         *  These are the GUI components
         */
        private Welcome agenda_welcome;
        private ListStore task_list;
        private TreeView tree_view;
        private ScrolledWindow scrolled_window;
        private HintedEntry task_entry;
        private Box vbox;

        public AgendaWindow () {    // Constructor
        
            this.app = app;
            this.title = "Agenda";      // Set the window title
            this.resizable = false;     // Window is not resizable
            this.set_keep_above (true); // Window stays on top of other windows
            
            /*
             *  Initialize the GUI components
             */
            agenda_welcome = new Welcome ("No Tasks!", "(way to go)");
            task_list = new ListStore (Columns.N_COLUMNS, typeof(bool), typeof(string), typeof(bool), typeof(string));
            scrolled_window = new ScrolledWindow (null, null);
            task_entry = new HintedEntry (HINT_STRING);
            vbox = new Box (Orientation.VERTICAL, 12);
            tree_view = new TreeView ();
            
            
            load_list ();
            setup_ui ();
            load_state ();
            
        }
        
        void load_list () {
            
            paths.initialize ("agenda", Build.PKGDATADIR);              // initialize directory paths for agenda
            paths.ensure_directory_exists (paths.user_data_folder);     // make sure the user specific agenda data directory exists
            
            list_file = paths.user_data_folder.get_child ("tasks");
            
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

        void setup_ui () {

            set_size_request (MIN_WIDTH, MIN_HEIGHT);   // set minimum window size
            destroy.connect (destroy_handler);          // see destroy_handler() method

            // setup tree_view
            tree_view.name = "TaskList";
            tree_view.headers_visible = false;          // disable headers
            tree_view.enable_search = false;            // disable live search
            tree_view.expand = true;                    // make it fill the container
            tree_view.reorderable = true;               // make it reorderable (drag and drop)
            
            /*
             * Attempt to set the treeview and welcome background transparent.
             * Code taken from Tom Beckmann's Agenda implementation.
             * lp:~tombeckmann/+junk/agenda
             *
             */
            var transp_css = new Gtk.CssProvider ();
            try {
                transp_css.load_from_data ("
                    GtkTreeView{background-color:@transparent;}
                    .view:selected:focused{color:@text_color;}
                ", -1);
            } catch (Error e) { warning (e.message); }
            tree_view.get_style_context ().add_provider (transp_css, 20000);
            
            transp_css = new Gtk.CssProvider ();
            try {
                transp_css.load_from_data ("
                    GtkEventBox{background-color:@transparent;}
                    .view:selected:focused{color:@text_color;}
                ", -1);
            } catch (Error e) { warning (e.message); }
            agenda_welcome.get_style_context ().add_provider (transp_css, 20000);
            
            /*
             *   Set up the TreeView with the necessary columns
             */
            var column = new TreeViewColumn ();
            var text = new CellRendererText ();         // CellRendererText to display the task description
            var toggle = new CellRendererToggle ();     // CellRendererToggle for checking it off the list
            var draghandle = new CellRendererPixbuf (); // CellRendererPixbuf to draw a pretty icon to make reordering easier
            
            // setup the TOGGLE column
            column = new TreeViewColumn.with_attributes ("Toggle", toggle, "active", Columns.TOGGLE);
            tree_view.append_column (column);

            // setup the TEXT column
            text.ypad = 6;                              // set vertical padding between rows
            text.editable = true;
            //text.ellipsize = Pango.EllipsizeMode.END;   // show ellipses at the end of a truncated task, instead of scrolling
            column = new TreeViewColumn.with_attributes ("Task", text, "text", Columns.TEXT, "strikethrough", Columns.STRIKETHROUGH);
            column.expand = true;                       // the text column should fill the whole width of the column
            tree_view.append_column (column);
            
            // setup the DRAGHANDLE column
            column = new TreeViewColumn.with_attributes ("Drag", draghandle, "stock_id", Columns.DRAGHANDLE);
            tree_view.append_column (column);
            tree_view.model = task_list;

            // setup the task entry
            task_entry.name = "TaskEntry";
            task_entry.max_length = 50;
            task_entry.hexpand = true;
            task_entry.secondary_icon_name = "add";


            // Method for when the task entry is activated
            task_entry.activate.connect (() => { add_task ( task_entry.text ); });
            task_entry.icon_press.connect ( () => { add_task (task_entry.text ); });

            // Method for editing tasks
            text.edited.connect ( (path, edited_text) => {
                Gtk.TreeIter iter;
                task_list.get_iter (out iter, new Gtk.TreePath.from_string (path));
                task_list.set (iter, 1, edited_text);
                list_to_file ();
            });

            // Method for when a task is toggled (completed)
            toggle.toggled.connect ((toggle, path) => {
                var tree_path = new TreePath.from_string (path);
                TreeIter iter;
                task_list.get_iter (out iter, tree_path);
                task_list.set (iter, Columns.TOGGLE, !toggle.active, Columns.STRIKETHROUGH, !toggle.active);

                Timeout.add (250, () => {
                    bool active; //check if it's still active
                    task_list.get (iter, 0, out active);
                    if (active)
                        task_list.remove (iter);
                        update ();
                        list_to_file ();
                    return false;
                });
            });
            
            
            // Method for when the user presses <Escape>, destroy the window
            this.key_press_event.connect ( (e) => {
                if (e.keyval == Gdk.Key.Escape)
                    this.destroy ();
                return false;
            });

            
            // setup the scrolled window and add tree_view
            scrolled_window.set_policy (PolicyType.NEVER, PolicyType.AUTOMATIC);
            scrolled_window.add (tree_view);
            
            vbox.margin = 12;        // elementary HIG states that widgets should be spaced 12px from the window border
            vbox.expand = true;      // expand the box to fill the whole window
            vbox.pack_start (agenda_welcome, true, true, 0);
            vbox.pack_start (scrolled_window, true, true, 0);
            vbox.pack_end (task_entry, false, false, 0);
            this.add (vbox);
            task_entry.grab_focus ();
        }

        void load_state () {
            set_default_size (state.width, state.height);   // Restore window geometry
        }

        void save_state () {
            Gtk.Allocation alloc;
            get_allocation (out alloc);     // get_size() is a lie.
            state.width = alloc.width;      // set the window width
            state.height = alloc.height;    // set the window height
        }

        void add_task (string task) {
            if (task == "") {    // if a task_entry is empty, don't add the task
                return;
            }
            
            TreeIter iter;
            task_list.append (out iter);
            task_list.set (iter, Columns.TOGGLE, false, Columns.TEXT, task, Columns.STRIKETHROUGH, false, Columns.DRAGHANDLE, Stock.JUSTIFY_FILL);
            update ();
            list_to_file ();
            task_entry.set_text("");        // clear the entry box
        }
        
        public void update () {        // if the task list is empty, show the welcome screen
            TreeIter iter;
            
            if ( !task_list.get_iter_first (out iter) ) // get_iter_first returns false if there are no items in the list
                show_welcome ();
            else
                hide_welcome ();
        }
        
        void show_welcome () {      // simply hides the scrolled_window and shows the welcome screen
            scrolled_window.hide ();
            agenda_welcome.show ();
        }
        
        void hide_welcome () {      // simply hides the welcome screen and shows the scrolled_window
            agenda_welcome.hide ();
            scrolled_window.show ();
        }
        
        public void list_to_file () {
        
            TreeIter iter;
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
        
        void destroy_handler () {   // Handles exiting (i.e. clicking the 'X' on the window or pressing <Esc>)
            save_state ();
            Gtk.main_quit ();
        }

    }
}

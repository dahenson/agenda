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
    // Limit for any edited text
    const int EDITED_TEXT_MAX_LEN = 64;

    const string HINT_STRING = _("Add a new task…");

    public class AgendaWindow : Gtk.ApplicationWindow {

        private GLib.Settings privacy_setting = new GLib.Settings (
            "org.gnome.desktop.privacy");

        private FileBackend backend;

        private Granite.Placeholder agenda_welcome;
        private TaskView task_view;
        private TaskList task_list;
        private Gtk.ScrolledWindow scrolled_window;
        private Gtk.Entry task_entry;
        private HistoryList history_list;

        public AgendaWindow (Agenda app) {
            Object (application: app);

            var window_close_action = new SimpleAction ("close", null);
            var app_quit_action = new SimpleAction ("quit", null);
            var undo_action = new SimpleAction ("undo", null);
            var redo_action = new SimpleAction ("redo", null);
            var print_action = new SimpleAction ("print", null);
            var purge_action = new SimpleAction ("remove_completed", null);
            var clear_history_action = new SimpleAction ("clear_history", null);
            var sort_action = new SimpleAction ("sort_completed", null);
            var help_action = new SimpleAction ("help", null);
            var prefs_action = new SimpleAction ("prefs", null);

            add_action (window_close_action);
            add_action (app_quit_action);
            add_action (undo_action);
            add_action (redo_action);
            add_action (print_action);
            add_action (purge_action);
            add_action (clear_history_action);
            add_action (sort_action);
            add_action (help_action);
            add_action (prefs_action);

            app.set_accels_for_action ("win.close", {"<Ctrl>W"});
            app.set_accels_for_action ("win.quit", {"<Ctrl>Q"});
            app.set_accels_for_action ("win.undo", {"<Ctrl>Z"});
            app.set_accels_for_action ("win.redo", {"<Ctrl><Shift>Z"});
            app.set_accels_for_action ("win.print", {"<Ctrl>P"});
            app.set_accels_for_action ("win.remove_completed", {"<Ctrl>R"});
            app.set_accels_for_action ("win.sort_completed", {"<Ctrl>S"});
            app.set_accels_for_action ("win.help", {"<Ctrl>H"});

            this.get_style_context ().add_class ("rounded");
            this.set_size_request (MIN_WIDTH, MIN_HEIGHT);

            var header = new Gtk.HeaderBar ();
            header.get_style_context ().add_class ("titlebar");
            this.set_titlebar (header);

            GLib.Menu menu = new GLib.Menu ();
            menu.append (_("Preferences"), "win.prefs");
            GLib.Menu section = new GLib.Menu ();
            section.append (_("Print task list"), "win.print");
            section.append (_("Remove completed"), "win.remove_completed");
            section.append (_("Sort completed"), "win.sort_completed");
            menu.insert_section (1, null, section);
            section = new GLib.Menu ();
            section.append (_("Help"), "win.help");
            section.append (_("_Quit"), "win.quit");
            menu.insert_section (4, null, section);

            Gtk.MenuButton burger = new Gtk.MenuButton ();
            burger.direction = Gtk.ArrowType.NONE;
            burger.menu_model = menu;
            header.pack_end (burger);

            // Set up geometry
            restore_window_position ();

            var first = Agenda.settings.get_boolean ("first-time");
            agenda_welcome = new Granite.Placeholder (_("No Tasks!")) {
                description = first ? _("(add one below)") : _("(way to go)")
            };

            agenda_welcome.vexpand = true;
            agenda_welcome.hexpand = true;

            task_list = new TaskList ();
            task_view = new TaskView.with_list (task_list);
            scrolled_window = new Gtk.ScrolledWindow ();
            task_entry = new Gtk.Entry ();

            history_list = new HistoryList ();

            if (first) {
                Agenda.settings.set_boolean ("first-time", false);
            }

            backend = new FileBackend ();

            load_list ();
            setup_ui ();

            window_close_action.activate.connect (this.main_quit);
            app_quit_action.activate.connect (this.main_quit);
            undo_action.activate.connect (task_list.undo);
            redo_action.activate.connect (task_list.redo);
            print_action.activate.connect (this.print);
            purge_action.activate.connect (task_list.remove_completed_tasks);
            clear_history_action.activate.connect (this.clear_history);
            sort_action.activate.connect (task_list.sort_tasks);
            help_action.activate.connect (this.help);
            prefs_action.activate.connect (this.open_prefs_window);
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
            close_request.connect (() => { main_quit (); return false; });

            task_entry.name = "TaskEntry";
            task_entry.get_style_context ().add_class ("task-entry");
            task_entry.placeholder_text = HINT_STRING;
            task_entry.max_length = EDITED_TEXT_MAX_LEN;
            task_entry.hexpand = true;
            task_entry.valign = Gtk.Align.START;
            task_entry.set_icon_tooltip_text (
                Gtk.EntryIconPosition.SECONDARY, _("Add to list…"));

            Gtk.EntryCompletion completion = new Gtk.EntryCompletion ();
            completion.set_model (history_list);
            completion.set_text_column (0);

            task_entry.set_completion (completion);

            setup_ctx_menu ();

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

            task_list.list_changed.connect (() => {
                backend.save_tasks (task_list.get_all_tasks ());
                update ();
            });

            var key_event_controller = new Gtk.EventControllerKey ();
            key_event_controller.key_pressed.connect (key_pressed);
            ((Gtk.Widget) this).add_controller ((Gtk.EventController) key_event_controller);

            task_view.hexpand = true;
            scrolled_window.hexpand = true;
            scrolled_window.vexpand = true;
            scrolled_window.set_policy (
                Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolled_window.set_child (task_view);

            var grid = new Gtk.Grid ();
            grid.hexpand = true;
            grid.row_homogeneous = false;
            grid.attach (agenda_welcome, 0, 0, 1, 1);
            grid.attach (scrolled_window, 0, 1, 1, 1);
            grid.attach (task_entry, 0, 2, 1, 1);

            this.set_child (grid);

            task_entry.margin_start = 10;
            task_entry.margin_end = 10;
            task_entry.margin_top = 10;
            task_entry.margin_bottom = 10;

            task_entry.grab_focus ();
        }

        private void setup_ctx_menu () {
            GLib.Menu menu = new GLib.Menu ();
            GLib.Menu section = new GLib.Menu ();
            GLib.MenuItem item = new GLib.MenuItem (_("Clear history"), "win.clear_history");
            section.append_item (item);

            menu.append_section (null, section);

            task_entry.extra_menu = menu;
        }

        public void append_task () {
            if (task_entry.text == "")
                return;

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
            var size = Agenda.settings.get_value ("window-size");
            var position = Agenda.settings.get_value ("window-position");

            /* positionning no longer possible in gtk4 */
            if (position.n_children () == 2) {
                var x = (int) position.get_child_value (0);
                var y = (int) position.get_child_value (1);
                debug ("Moving window to coordinates %d, %d", x, y);
                /*
                move (x, y);
                */
            } else {
                debug ("Moving window to the centre of the screen");
                /*
                window_position = Gtk.WindowPosition.CENTER;
                */
            }

            if (size.n_children () == 2) {
                int width = (int) size.get_child_value (0);
                int height = (int) size.get_child_value (1);

                debug ("Resizing to width and height: %d, %d", width, height);
                this.set_default_size (width, height);
            } else {
                this.set_default_size (MIN_WIDTH, MIN_HEIGHT);
                debug ("Not resizing window");
            }
        }

        public void main_quit () {
            backend.save_tasks (task_list.get_all_tasks ());
            backend.save_history (history_list.get_all_tasks ());
            save_geometry ();
            close ();
        }

        public bool key_pressed (Gtk.EventControllerKey controller, uint keyval, uint keycode,
                                 Gdk.ModifierType state) {
            switch (keyval) {
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

        void save_geometry () {
            //int x, y;
            Gdk.Rectangle rect;

            /* no more get_position in gtk4 */
            //get_position (out x, out y);
            get_allocation (out rect);

            /*
            debug ("Saving window position to %d, %d", x, y);
            Agenda.settings.set_value (
                "window-position", new int[] { x, y });
            */
            debug (
                "Saving window size of width and height: %d, %d",
                rect.width, rect.height);
            Agenda.settings.set_value (
                "window-size", new int[] { rect.width, rect.height });
        }

        void clear_history () {
            history_list.clear ();
        }

        public void print () {
                Gtk.PrintOperation print = new Gtk.PrintOperation ();
                print.begin_print.connect (task_list.begin_print);
                print.draw_page.connect (task_list.draw_page);
                try {
                        var res = print.run (Gtk.PrintOperationAction.PRINT_DIALOG, this);
                        debug ("print res: %d\n", res);
                } catch (Error e) {
                        error (e.message);
                }
        }

        public void help () {
            var builder = new Gtk.Builder ();
            try {
                builder.add_from_resource ("/com/github/dahenson/agenda/shortcuts.ui");
                var window = builder.get_object ("shortcuts-agenda") as Gtk.ShortcutsWindow;
                window.view_name = null;
                window.set_transient_for (this);
                window.present ();
            } catch (Error e) {
                error (e.message);
            }
        }

        void open_prefs_window () {
            PrefsWindow w = new PrefsWindow (this);
            w.present ();
        }
    }
}

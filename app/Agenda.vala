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

    public class Application : Gtk.Application {
        public static GLib.Settings settings;
        public static Agenda.TaskRepositoryFile tasks;
        private Agenda.Window window = null;

        public Application () {
            Object (application_id: "com.github.dahenson.agenda");

            settings = new GLib.Settings ("com.github.dahenson.agenda");

            var dir = get_agenda_dir ();
            tasks = new TaskRepositoryFile (dir);
        }

        private GLib.File get_agenda_dir () {
            string user_data = Environment.get_user_data_dir ();

            File dir = File.new_for_path (user_data).get_child ("agenda");

            try {
                dir.make_directory_with_parents ();
            } catch (Error e) {
                if (e is IOError.EXISTS) {
                    info ("%s", e.message);
                } else {
                    error ("Could not access or create directory '%s'.",
                           dir.get_path ());
                }
            }

            return dir;
        }

        protected override void activate () {
            if (window != null) {
                window.present ();
                return;
            }

            window = new Agenda.Window (this);
            window.delete_event.connect (window.main_quit);
            window.show_all ();
            window.update ();
        }

        public static int main (string[] args) {
            return new Agenda.Application ().run (args);
        }
    }

}

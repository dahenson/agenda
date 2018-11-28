/***

    Copyright (C) 2014-2018 Agenda Developers

    This file is part of Agenda.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

***/

using Gtk;
using Granite;

namespace Agenda {

    public class Agenda : Gtk.Application {

        private static Agenda app;
        private AgendaWindow window = null;

        public Agenda () {
            Object (application_id: "com.github.dahenson.agenda",
            flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate () {
            // if app is already open
            if (window != null) {
                window.present ();
                return;
            }

            window = new AgendaWindow ();
            window.set_application (this);
            window.delete_event.connect(window.main_quit);
            window.show_all ();
            window.update ();

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("com/github/dahenson/agenda/Agenda.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        public static Agenda get_instance () {
            if (app == null) {
                app = new Agenda ();
            }

            return app;
        }

        public static int main (string[] args) {

            app = new Agenda ();

            if (args[1] == "-s") {
                return 0;
            }

            return app.run (args);
        }
    }
}

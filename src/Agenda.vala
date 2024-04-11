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

using Gtk;
using Granite;

namespace Agenda {

    public class Agenda : Gtk.Application {
        public static GLib.Settings settings;
        private static Agenda app;
        private AgendaWindow window = null;

        static construct {
            settings = new GLib.Settings ("com.github.dahenson.agenda");
        }

        public Agenda () {
            Object (application_id: Build.APPNAME == "agenda" ? null : Build.APPNAME,
            flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate () {
            if (window != null) {
                window.present ();
                return;
            }

            /* follow system drak/light theme */
            var granite_settings = Granite.Settings.get_default ();
            var gtk_settings = Gtk.Settings.get_default ();
            gtk_settings.gtk_application_prefer_dark_theme =
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            granite_settings.notify["prefers-color-scheme"].connect (() => {
                gtk_settings.gtk_application_prefer_dark_theme =
                    granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            });

            window = new AgendaWindow (this);
            window.present ();
            window.update ();

            if (elementary_stylesheet ()) {
                var elementary_provider = new Gtk.CssProvider ();
                elementary_provider.load_from_resource (
                    "com/github/dahenson/agenda/Agenda.css");
                Gtk.StyleContext.add_provider_for_display (
                    Gdk.Display.get_default (),
                    elementary_provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
        }

        public static Agenda get_instance () {
            if (app == null) {
                app = new Agenda ();
            }

            return app;
        }

        public static int main (string[] args) {
            Intl.setlocale (GLib.LocaleCategory.ALL, "");
            Intl.bindtextdomain (Build.APPNAME, Build.PREFIX + "/share/locale");
            Intl.textdomain (Build.APPNAME);

            app = new Agenda ();

            if (args.length == 2 && args[1] == "-s") {
                return 0;
            }

            return app.run (args);
        }

        public static bool elementary_stylesheet () {
            return Gtk.Settings.get_default ().gtk_theme_name.contains
                ("elementary");
        }
    }
}

/***

    Copyright (C) 2014-2017 Agenda Developers

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
    }

    public static Agenda get_instance () {
        if (app == null)
            app = new Agenda ();

        return app;
    }

    public static int main (string[] args) {
 
        // Init internationalization support
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bind_textdomain_codeset (Build.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Build.GETTEXT_PACKAGE);

        app = new Agenda ();
            
        if (args[1] == "-s") {
            return 0;
        }
 
        return app.run (args);
    }
}
}

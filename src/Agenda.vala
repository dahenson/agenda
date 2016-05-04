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

using Gtk;
using Granite;

namespace Agenda {

public class Agenda : Granite.Application {

	private static Agenda app;
	private AgendaWindow window = null;

	construct {

		// App info
		build_version = Build.VERSION;
		build_data_dir = Build.DATADIR;
		build_pkg_data_dir = Build.PKGDATADIR;
		build_release_name = Build.RELEASE_NAME;
		build_version_info = Build.VERSION_INFO;

		program_name = "Agenda";
		exec_name = "agenda";

		app_years = "2012-2016";
		application_id = "net.launchpad.agenda-tasks";
		app_icon = "agenda";
		app_launcher = "agenda.desktop";

		main_url = "https://launchpad.net/agenda-tasks";
		bug_url = "https://bugs.launchpad.net/agenda-tasks";
		help_url = "https://answers.launchpad.net/agenda-tasks";
		translate_url = "https://translations.launchpad.net/agenda-tasks";
        
		about_authors = {"Tom Beckmann <tombeckmann@online.de>",
		                 "Dane Henson <dane.henson@gmail.com>",
		                 "Cameron Norman <camerontnorman@gmail.com>",
		                 "Fabio Zaramella <ffabio.96.x@gmail.com>"};
		about_documenters = {"Dane Henson <dane.henson@gmail.com",
		                     "Tom Beckmann <tombeckmann@online.de>"};
		about_artists = {"Harvey Cabaguio", "Sergey Davidoff"};
		about_comments = _("A simple, slick, speedy, and no-nonsense task manager.");
		about_translators = "";
		about_license_type = Gtk.License.GPL_3_0;
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

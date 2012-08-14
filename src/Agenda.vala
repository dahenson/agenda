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

using Gtk;
using Granite;

namespace Agenda {

    public class Agenda : Granite.Application {

        private AgendaWindow window = null;

        construct {

            program_name = "Agenda";
            exec_name = "agenda";

            app_years = "2012";
            application_id = "net.launchpad.agenda";
            app_icon = "application-default-icon";
            app_launcher = "agenda.desktop";

            main_url = "https://code.launchpad.net/agenda";
            bug_url = "https://bugs.launchpad.net/agenda";
            help_url = "https://code.launchpad.net/agenda";
            translate_url = "https://translations.launchpad.net/agenda";
        
            about_authors = {"Dane Henson <dane.henson@gmail.com>, Tom Beckmann <tombeckmann@online.de>"};
            about_documenters = {"Dane Henson <dane.henson@gmail.com, Tom Beckmann <tombeckmann@online.de>"};
            about_artists = {"Harvey Cabaguio, Sergey Davidoff"};
            about_comments = "Development release, not all features implemented";
            about_translators = "";
            about_license_type = Gtk.License.GPL_3_0;
        }

        protected override void activate () {
                        
            if (window != null) {
                window.present (); // present window if app is already open
                return;
            }
            
            window = new AgendaWindow ();
            window.set_application (this);
            window.show_all ();
            window.update ();
        }

    	public static int main (string[] args) {
	        
	        var app = new Agenda ();
	        
	        if (args[1] == "-s") {
		        return 0;
	        }
	        
	        return app.run (args);
        }
    }
}

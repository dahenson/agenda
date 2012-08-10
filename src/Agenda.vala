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

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

    public class PrefsWindow : Gtk.Window {
        public static GLib.Settings settings;
        Gtk.FontButton font_button;
        Gtk.Switch sort_switch;

        public PrefsWindow (AgendaWindow win) {
            Object ();

            settings = new GLib.Settings (Build.APPNAME);

            this.set_transient_for (win);
            this.set_modal (true);

            var header = new Gtk.HeaderBar ();
            header.get_style_context ().add_class ("titlebar");
            this.set_titlebar (header);

            setup_ui ();
        }

        private void setup_ui () {
            this.set_title (_("Preferences"));

            var font_hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            Gtk.Label font_label = new Gtk.Label (_("Printing font"));
            font_label.hexpand = true;

            this.font_button = new Gtk.FontButton ();
            font_button.set_font (settings.get_string ("print-font-description"));

            font_hbox.spacing = 6;
            font_hbox.append (font_label);
            font_hbox.append (font_button);

            var sort_hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            Gtk.Label sort_label = new Gtk.Label (_("Sort completed tasks upward"));
            sort_label.hexpand = true;

            this.sort_switch = new Gtk.Switch ();
            sort_switch.set_active (settings.get_boolean ("sort-completed-upward"));

            sort_hbox.spacing = 6;
            sort_hbox.append (sort_label);
            sort_hbox.append (sort_switch);

            var buttonbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
            buttonbox.homogeneous = true;
            buttonbox.hexpand = true;

            Gtk.Button cancel = new Gtk.Button.with_label (_("Cancel"));
            cancel.halign = Gtk.Align.START;
            Gtk.Button ok = new Gtk.Button.with_label (_("OK"));
            ok.halign = Gtk.Align.END;

            buttonbox.append (cancel);
            buttonbox.append (ok);

            var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
            vbox.spacing = 6;
            vbox.margin_end = vbox.margin_start = vbox.margin_top = vbox.margin_bottom = 6;
            vbox.append (font_hbox);
            vbox.append (sort_hbox);
            vbox.append (buttonbox);

            ok.clicked.connect (this.on_ok);
            cancel.clicked.connect (this.on_cancel);
            this.set_child (vbox);
        }

        void on_ok () {
            settings.set_string ("print-font-description", font_button.get_font ());
            settings.set_boolean ("sort-completed-upward", sort_switch.get_active ());
            this.destroy ();
        }

        void on_cancel () {
            this.destroy ();
        }
    }
}

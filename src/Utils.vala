/***

    Copyright (C) 2014-2015 Agenda Developers

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

namespace Agenda {

    private Notify.Notification? notification = null;

    public static void show_notification (string primary_text, string secondary_text) {

        int urgency = Notify.Urgency.NORMAL;

        if (!Notify.is_initted ()) {
            if (!Notify.init (Agenda.get_instance ().application_id)) {
                warning ("Could not init libnotify");
                return;
            }
        }

        if (notification == null) {
            notification = new Notify.Notification (primary_text, secondary_text, "");
        } else {
            notification.clear_hints ();
            notification.clear_actions ();
            notification.update (primary_text, secondary_text, "");
        }

        notification.icon_name = Agenda.get_instance ().app_icon;

        notification.set_urgency ((Notify.Urgency) urgency);

        try {
            notification.show ();
        } catch (GLib.Error err) {
            warning ("Could not show notification: %s", err.message);
        }
    }
}

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

namespace Agenda {

    private GLib.Notification notification = null;
    private GLib.NotificationPriority priority = GLib.NotificationPriority.LOW;

    public static void show_notification (string primary_text, string secondary_text) {

        if (notification == null) {
            notification = new GLib.Notification (primary_text);
            notification.set_body (secondary_text);
        } else {
            notification.set_title (primary_text);
            notification.set_body (secondary_text);
        }

        try {
            notification.set_icon (GLib.Icon.new_for_string (Agenda.get_instance ().app_icon));
        } catch (GLib.Error e) {
            warning ("Couldn't find Agenda icon. Default app icon will be used instead.");
            notification.set_icon (GLib.Icon.new_for_string ("application-default-icon"));
        }

        notification.set_priority (priority);

        try {
            GLib.Application.get_default ().send_notification (Agenda.get_instance ().exec_name, notification);
        } catch (GLib.Error err) {
            warning ("Could not show notification: %s", err.message);
        }
    }
}

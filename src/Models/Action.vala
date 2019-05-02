/***

    Copyright (C) 2014-2018 Agenda Developers

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

    public enum ActionType {
        NOOP,
        APPENDED,
        REMOVED,
        EDITED,
        MOVED,
        TOGGLED
    }

    public class Action : GLib.Object {
        public string id { get; private set; }
        public string text { get; private set; }
        public ActionType action_type { get; private set; }

        public Action (string id, string text, ActionType action_type) {
            this.id = id;
            this.text = text;
            this.action_type = action_type;
        }

        public bool equal (Action action) {
            if (this.id == action.id &&
                this.text == action.text &&
                this.action_type == action.action_type) {
                return true;
            } else {
                return false;
            }
        }
    }
}

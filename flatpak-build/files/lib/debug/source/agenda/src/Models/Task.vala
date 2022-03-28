/***

    Copyright (C) 2014-2020 Agenda Developers

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

    public class Task : GLib.Object {
        public string id { get; set; default = ""; }
        public bool complete { get; set; default = false; }
        public string text { get; set; default = ""; }

        public Task () {
        }

        public Task.with_attributes (string id, bool complete, string text) {
            Object (
                id: id,
                complete: complete,
                text: text);
        }

        public string to_string () {
            string str;

            if (this.complete) {
                str = "t," + this.text;
            } else {
                str = "f," + this.text;
            }

            return str;
        }
    }
}

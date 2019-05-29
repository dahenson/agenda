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

    public class TaskListHistory : GLib.Object {

        private Gee.ArrayList<TaskList> list;
        private Gee.BidirListIterator<TaskList> iter;

        construct {
            list = new Gee.ArrayList<TaskList> ();
            iter = list.bidir_list_iterator ();
        }

        public int size {
            public get { return list.size; }
        }

        public bool has_previous_state {
            public get;
            private set;
            default = false;
        }

        public void add (TaskList state) {
            iter.add (state);

            if (!has_previous_state) {
                has_previous_state = true;
            }
        }

        public TaskList? get_previous_state () {
            if (iter.valid && has_previous_state) {
                var state = iter.get ();

                if (iter.has_previous ()) {
                    iter.previous ();
                } else {
                    has_previous_state = false;
                }

                return state;
            } else {
                return null;
            }
        }
    }
}

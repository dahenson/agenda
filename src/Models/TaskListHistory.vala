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

        private Gee.LinkedList<TaskList> list;
        private Gee.BidirListIterator<TaskList> iter;

        construct {
            list = new Gee.LinkedList<TaskList> ();
            iter = list.bidir_list_iterator ();
        }

        public int size {
            public get { return list.size; }
        }

        public int index {
            public get { return iter.index (); }
        }

        public void add (TaskList state) {
            if (iter.has_next ()) {
                var temp_list = list.slice (0, iter.index () + 1);
                list.retain_all (temp_list);
            }

            TaskList current_state = state.copy ();

            list.add (current_state);
            iter = list.bidir_list_iterator ();
            iter.last ();
        }

        public TaskList? get_next_state () {
            if (iter.next ()) {
                return iter.@get ();
            } else {
                return null;
            }
        }

        public TaskList? get_previous_state () {
            if (iter.previous ()) {
                var state = iter.@get ();
                return state;
            } else {
                return null;
            }
        }
    }
}

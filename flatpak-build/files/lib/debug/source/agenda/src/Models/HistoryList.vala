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

    public class HistoryList : Gtk.ListStore {

        construct {
            Type[] types = { typeof (string) };
            set_column_types (types);
        }

        public void add_item (string text) {
            Gtk.TreeIter iter;
            string row;
            bool valid = get_iter_first (out iter);

            if (valid == false) {
                append (out iter);
                set (iter, 0, text);
            } else {
                while (valid) {
                    get (iter, 0, out row);
                    if (row == text) {
#if VALA_0_36
                        remove (ref iter);
#else
                        remove (iter);
#endif
                    }

                    valid = iter_next (ref iter);
                }

                append (out iter);
                set (iter, 0, text);
            }
        }

        /**
         * Gets all tasks in the list
         *
         * @return Array of items from the list
         */
        public string[] get_all_tasks () {
            Gtk.TreeIter iter;
            bool valid = get_iter_first (out iter);

            string[] items = {};

            while (valid) {
                string text;
                get (iter, 0, out text);
                items += text;
                valid = iter_next (ref iter);
            }

            return items;
        }
    }
}

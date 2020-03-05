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

    public void load_list () {
    }

    public void save_list (string[] list, File file) {
        try {
            if (file.query_exists ()) {
                file.delete ();
            }

            var file_dos = new DataOutputStream (
                file.create (FileCreateFlags.REPLACE_DESTINATION));
            foreach (string item in list) {
                file_dos.put_string (item + "\n");
            }
        } catch (Error e) {
            error ("Error: %s\n", e.message);
        }
    }
}

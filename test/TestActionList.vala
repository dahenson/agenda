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

void add_action_list_tests () {
    Test.add_func ("/action_list/add", () => {
        var list = new Agenda.ActionList ();
        var task1 = new Agenda.Action (
            "id",
            "text",
            Agenda.ActionType.EDITED);

        list.add (task1);

        assert (task1.equal (list.last ()));
    });
}

void main (string[] args) {
    Test.init (ref args);
    add_action_list_tests ();
    Test.run ();
}

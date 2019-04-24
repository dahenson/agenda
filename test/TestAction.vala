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

void add_action_tests () {
    Test.add_func ("/action/new", () => {
        var action_id = Uuid.string_random ();
        var text = "This is a task";
        var action_type = Agenda.ActionType.DELETED;

        var action = new Agenda.Action (
            action_id,
            text,
            action_type);

        assert (action.id == action_id);
        assert (action.text == text);
        assert (action.action_type == action_type);
    });

    Test.add_func ("/action/equal", () => {
        var action_id = Uuid.string_random ();
        var text = "task";
        var action_type = Agenda.ActionType.DELETED;

        var action1 = new Agenda.Action (
            action_id,
            text,
            action_type);

        var action2 = new Agenda.Action (
            action_id,
            text,
            action_type);

        var action3 = new Agenda.Action (
            "id",
            "text",
            Agenda.ActionType.DELETED);

        assert (action1.equal (action2));
        assert (!action2.equal (action3));
    });
}

void main (string[] args) {
    Test.init (ref args);
    add_action_tests ();
    Test.run ();
}
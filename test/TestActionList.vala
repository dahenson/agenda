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

using Agenda;

public class ActionListTests : Gee.TestCase {

    private ActionList test_list;
    private Agenda.Action action1;
    private Agenda.Action action2;
    private Agenda.Action action3;

    public ActionListTests () {
        base ("Agenda");
        add_test ("[ActionList] test basic functions", test_basic_functions);
        add_test ("[ActionList] test get_previous_action", test_get_previous_action);
    }

    public override void set_up () {
        test_list = new ActionList ();

        action1 = new Agenda.Action (
            "id1",
            "text1",
            Agenda.Action.REMOVED);

        action2 = new Agenda.Action (
            "id2",
            "text2",
            Agenda.Action.EDITED);

        action3 = new Agenda.Action (
            "id3",
            "text3",
            Agenda.Action.TOGGLED);
    }

    public override void tear_down () {
        test_list = null;
        action1 = null;
        action2 = null;
        action3 = null;
    }

    public void test_basic_functions () {
        test_list.add (action1);
        test_list.add (action2);
        test_list.add (action3);
        assert (test_list.size == 3);
    }

    public void test_get_previous_action () {
        test_list.add (action1);
        test_list.add (action2);
        assert (test_list.has_previous_action);
        assert (action2.equal (test_list.get_previous_action ()));
        assert (test_list.size == 2);

        assert (test_list.has_previous_action);
        assert (action1.equal (test_list.get_previous_action ()));
        assert (test_list.size == 2);

        assert (!test_list.has_previous_action);
        assert (test_list.get_previous_action () == null);
    }
}


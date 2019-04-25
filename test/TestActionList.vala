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

    public ActionListTests () {
        base ("ActionList");
        add_test ("[ActionList] test basic functions", test_basic_functions);
    }

    public override void set_up () {
        test_list = new ActionList ();

        action1 = new Agenda.Action (
            "id1",
            "text1",
            Agenda.Action.DELETED);

        action2 = new Agenda.Action (
            "id2",
            "text2",
            Agenda.Action.EDITED);
    }

    public override void tear_down () {
        test_list = null;
        action1 = null;
        action2 = null;
    }

    public void test_basic_functions () {
        test_list.add (action1);
        test_list.add (action2);
        assert (action2.equal (test_list.last ()));
    }
}


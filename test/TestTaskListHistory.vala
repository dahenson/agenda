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

using Agenda;

public class TaskListHistoryTests : Gee.TestCase {

    private TaskListHistory test_list;
    private TaskList list;

    public TaskListHistoryTests () {
        base ("Agenda");
        add_test ("[TaskListHistory] test add", test_add);
        add_test ("[TaskListHistory] test get_previous_state",
                  test_get_previous_state);
        add_test ("[TaskListHistory] test get_next_state",
                  test_get_next_state);
    }

    public override void set_up () {
        test_list = new TaskListHistory ();
        list = new TaskList ();
    }

    public override void tear_down () {
        test_list = null;
        list = null;
    }

    public void test_add () {
        assert (test_list.size == 0);

        test_list.add (list);
        test_list.add (list);

        assert (test_list.size == 2);
    }

    public void test_get_previous_state () {
        assert (test_list.get_previous_state () == null);

        test_list.add (list);

        list.append_task ("First Task");
        test_list.add (list);

        list.append_task ("Second Task");
        test_list.add (list);

        assert (test_list.size == 3);

        var one_task = test_list.get_previous_state ();
        assert (one_task.size == 1);

        assert (test_list.get_previous_state () != null);
        assert (test_list.get_previous_state () == null);
        assert (test_list.size == 3);
    }

    public void test_get_next_state () {
        assert (test_list.get_next_state () == null);

        test_list.add (list);
        test_list.add (list);
        test_list.add (list);
        assert (test_list.size == 3);

        test_list.get_previous_state ();
        test_list.get_previous_state ();

        assert (test_list.get_next_state () != null);
        assert (test_list.size == 3);

        test_list.get_previous_state ();
        test_list.add (list);
        assert (test_list.size == 2);
    }
}

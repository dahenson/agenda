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

public class TaskListTests : Gee.TestCase {

    private TaskList test_list;

    public TaskListTests () {
        base ("TaskList");
        add_test ("[TaskList] test basic functions", test_basic_functions);
        add_test ("[TaskList] test append function", test_append_function);
    }

    public override void set_up () {
        test_list = new TaskList ();
    }

    public override void tear_down () {
        test_list = null;
    }

    public void test_basic_functions () {
        assert (test_list.iter_n_children (null) == 0);
        assert (!test_list.contains ("whatever"));

        var task = test_list.append_task ("a task");

        assert (test_list.contains (task));
    }

    public void test_append_function () {
        var task1 = test_list.append_task ("a new task");
        var task2 = test_list.append_task ("another new task");

        assert (test_list.iter_n_children (null) == 2);
        assert (test_list.contains (task1));
        assert (test_list.contains (task2));
    }
}


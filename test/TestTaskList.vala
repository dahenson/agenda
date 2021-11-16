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

public class TaskListTests : Gee.TestCase {

    private Agenda.Task test_task_1;
    private Agenda.Task test_task_2;

    private Agenda.TaskList test_list;

    public static void main (string[] args) {
        Test.init (ref args);

        TestSuite.get_root ().add_suite (new TaskListTests ().get_suite ());

        Test.run ();
    }

    public TaskListTests () {
        base ("TaskList");
        add_test ("add", test_add);
        add_test ("remove", test_remove);
    }

    public override void set_up () {
        test_list = new Agenda.TaskList ();

        test_task_1 = new Agenda.Task.with_attributes ("1", false, "foo");
        test_task_2 = new Agenda.Task.with_attributes ("2", true, "bar");
    }

    public override void tear_down () {
        test_list = null;

        test_task_1 = null;
        test_task_2 = null;
    }

    public void test_add () {
        test_list.add (test_task_1);
        assert_true (test_list.size == 1);
        assert_true (test_list.contains (test_task_1));

        test_list.add (test_task_2);
        assert_true (test_list.size == 2);
        assert_true (test_list.contains (test_task_2));

        var t = test_list.first ();
        assert_true (Agenda.Task.eq (test_task_1, t));

        t = test_list.last ();
        assert_true (Agenda.Task.eq (test_task_2, t));
    }

    public void test_remove () {
        test_list.add (test_task_1);
        test_list.add (test_task_2);
        assert_true (test_list.size == 2);

        assert_true (test_list.remove (test_task_2));

        var t = test_list.last ();
        assert_true (Agenda.Task.eq (test_task_1, t));
    }
}

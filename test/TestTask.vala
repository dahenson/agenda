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

public class TaskTests : Gee.TestCase {

    public static void main (string[] args) {
        Test.init (ref args);

        TestSuite.get_root ().add_suite (new TaskTests ().get_suite ());

        Test.run ();
    }

    public TaskTests () {
        base ("Task");
        add_test ("with_attributes", test_with_attributes);
        add_test ("to_string", test_to_string);
        add_test ("equal_to", test_equal_to);
    }

    public override void set_up () {
    }

    public override void tear_down () {
    }

    public void test_with_attributes () {
        var test_task = new Agenda.Task.with_attributes ("foo", true, "bar");
        assert_true (test_task.id == "foo");
        assert_true (test_task.complete == true);
        assert_true (test_task.text == "bar");
    }

    public void test_to_string () {
        var test_task = new Agenda.Task.with_attributes ("foo", true, "bar");
        assert_true (test_task.to_string () == "t," + test_task.text);
    }

    public void test_equal_to () {
        var task_1 = new Agenda.Task.with_attributes ("foo", true, "bar");
        var task_2 = new Agenda.Task.with_attributes ("baz", false, "bar");

        assert_false (Agenda.Task.eq (task_1, task_2));

        task_1.id = task_2.id;
        task_1.complete = task_2.complete;
        task_1.text = task_2.text;
        assert_true (Agenda.Task.eq (task_1, task_2));
    }
}

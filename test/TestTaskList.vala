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
        base ("Agenda");
        add_test ("[TaskList] test basic functions", test_basic_functions);
        add_test ("[TaskList] test append", test_append);
        add_test ("[TaskList] test remove_task", test_remove_task);
        add_test ("[TaskList] test undo append", test_undo_append);
        add_test ("[TaskList] test undo remove", test_undo_remove);
        add_test ("[TaskList] test redo append", test_redo_append);
        add_test ("[TaskList] test copy", test_copy);
    }

    public override void set_up () {
        test_list = new TaskList ();
    }

    public override void tear_down () {
        test_list = null;
    }

    public void test_basic_functions () {
        assert (test_list.size == 0);
        assert (!test_list.contains ("whatever"));

        var task = test_list.append_task ("a task");

        assert (test_list.contains (task));
    }

    public void test_append () {
        var task1 = test_list.append_task ("a new task");
        var task2 = test_list.append_task ("another new task");

        assert (test_list.size == 2);
        assert (test_list.contains (task1));
        assert (test_list.contains (task2));
    }

    public void test_remove_task () {
        var task1 = test_list.append_task ("a new task");
        var task2 = test_list.append_task ("another new task");

        Gtk.TreePath path = new Gtk.TreePath.from_string ("0");

        assert (test_list.remove_task (path));
        assert (test_list.size == 1);
        assert (!test_list.contains (task1));
        assert (test_list.contains (task2));
    }

    public void test_undo_append () {
        test_list.clear_undo ();
        var task1 = test_list.append_task ("a new task");
        var task2 = test_list.append_task ("another new task");

        assert (test_list.size == 2);

        test_list.undo ();
        assert (test_list.size == 1);
        assert (!test_list.contains (task2));
        assert (test_list.contains (task1));

        test_list.undo ();
        assert (test_list.size == 0);
    }

    public void test_undo_remove () {
        test_list.clear_undo ();
        test_list.append_task ("a new task");
        test_list.append_task ("another task");
        var task3 = test_list.append_task ("last task");
        assert (test_list.size == 3);

        Gtk.TreePath path = new Gtk.TreePath.from_string ("2");
        assert (test_list.remove_task (path));
        assert (!test_list.contains (task3));
        assert (test_list.size == 2);

        test_list.undo ();
        assert (test_list.contains (task3));
        assert (test_list.size == 3);
    }

    public void test_redo_append () {
        test_list.clear_undo ();
        var task1 = test_list.append_task ("a new task");
        var task2 = test_list.append_task ("another new task");

        assert (test_list.size == 2);

        test_list.undo ();
        test_list.undo ();

        test_list.redo ();
        assert (test_list.size == 1);
        assert (test_list.contains (task1));

        test_list.redo ();
        assert (test_list.size == 2);
        assert (test_list.contains (task2));
    }

    public void test_copy () {
        TaskList list_copy = test_list.copy ();
        assert (list_copy.size == 0);

        test_list.append_task ("a new task");
        test_list.append_task ("another task");
        var task3 = test_list.append_task ("last task");
        assert (test_list.size == 3);

        list_copy = test_list.copy ();
        assert (list_copy.size == 3);
        assert (test_list.contains (task3));

        Gtk.TreePath path = new Gtk.TreePath.from_string ("2");
        assert (test_list.remove_task (path));
        assert (!test_list.contains (task3));
    }
}


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

public class TaskListTests : Gee.TestCase {

    private Agenda.Task test_task_1;
    private Agenda.Task test_task_2;
    private Agenda.Task test_task_3;

    private TaskList test_list;

    public TaskListTests () {
        base ("Agenda");
        add_test ("[TaskList] test basic functions", test_basic_functions);
        add_test ("[TaskList] test append", test_append);
        add_test ("[TaskList] test get_all_tasks", test_get_all_tasks);
        add_test ("[TaskList] test get_task", test_get_task);
        add_test ("[TaskList] test remove_task", test_remove_task);
        add_test ("[TaskList] test toggle_task", test_toggle_task);
        add_test ("[TaskList] test set_task_text", test_set_task_text);
        add_test ("[TaskList] test undo append", test_undo_append);
        add_test ("[TaskList] test undo remove", test_undo_remove);
        add_test ("[TaskList] test redo append", test_redo_append);
        add_test ("[TaskList] test drag reorder", test_undo_drag_reorder);
        add_test ("[TaskList] test copy", test_copy);
        add_test ("[TaskList] test load_tasks", test_load_tasks);
    }

    public override void set_up () {
        test_list = new TaskList ();

        test_task_1 = new Agenda.Task.with_attributes ("1", false, "foo");
        test_task_2 = new Agenda.Task.with_attributes ("2", true, "bar");
        test_task_3 = new Agenda.Task.with_attributes ("3", false, "baz");
    }

    public override void tear_down () {
        test_list = null;

        test_task_1 = null;
        test_task_2 = null;
    }

    public void test_basic_functions () {
        assert (test_list.size == 0);
        assert (!test_list.contains ("whatever"));

        test_list.append_task (test_task_1);

        assert (test_list.contains (test_task_1.id));
    }

    public void test_append () {
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);

        assert (test_list.size == 2);
        assert (test_list.contains (test_task_1.id));
        assert (test_list.contains (test_task_2.id));
    }

    public void test_get_all_tasks () {
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);
        test_list.append_task (test_task_3);

        Agenda.Task[] tasks = test_list.get_all_tasks ();

        assert (tasks.length == 3);
        assert (tasks[0].id == test_task_1.id);
        assert (tasks[1].id == test_task_2.id);
        assert (tasks[2].id == test_task_3.id);
    }

    public void test_get_task () {
        test_list.append_task (test_task_1);

        Gtk.TreeIter iter;
        test_list.get_iter_first (out iter);

        Agenda.Task t = test_list.get_task (iter);
        assert (t.complete == test_task_1.complete);
        assert (t.text == test_task_1.text);
    }

    public void test_remove_task () {
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);

        Gtk.TreePath path = new Gtk.TreePath.from_string ("0");

        assert (test_list.remove_task (path));
        assert (test_list.size == 1);
        assert (!test_list.contains (test_task_1.id));
        assert (test_list.contains (test_task_2.id));
    }

    public void test_toggle_task () {
        test_list.append_task (test_task_1);

        var tree_path = new Gtk.TreePath.from_string ("0");
        test_list.toggle_task (tree_path);

        Gtk.TreeIter iter;
        test_list.get_iter (out iter, tree_path);

        var t = test_list.get_task (iter);
        assert (t.complete == !test_task_1.complete);
    }

    public void test_set_task_text () {
        test_list.append_task (test_task_1);
        test_list.set_task_text ("0", "New Text");

        Gtk.TreeIter iter;
        var tree_path = new Gtk.TreePath.from_string ("0");
        test_list.get_iter (out iter, tree_path);

        var t = test_list.get_task (iter);
        assert (t.text == "New Text");
    }

    public void test_undo_append () {
        test_list.clear_undo ();
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);

        assert (test_list.size == 2);

        test_list.undo ();
        assert (test_list.size == 1);
        assert (!test_list.contains (test_task_2.id));
        assert (test_list.contains (test_task_1.id));

        test_list.undo ();
        assert (test_list.size == 0);
    }

    public void test_undo_remove () {
        test_list.clear_undo ();
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);
        test_list.append_task (test_task_3);
        assert (test_list.size == 3);

        Gtk.TreePath path = new Gtk.TreePath.from_string ("2");
        assert (test_list.remove_task (path));
        assert (!test_list.contains (test_task_3.id));
        assert (test_list.size == 2);

        test_list.undo ();
        assert (test_list.contains (test_task_3.id));
        assert (test_list.size == 3);
    }

    public void test_redo_append () {
        test_list.clear_undo ();
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);

        assert (test_list.size == 2);

        test_list.undo ();
        test_list.undo ();

        test_list.redo ();
        assert (test_list.size == 1);
        assert (test_list.contains (test_task_1.id));

        test_list.redo ();
        assert (test_list.size == 2);
        assert (test_list.contains (test_task_2.id));
    }

    public void test_undo_drag_reorder () {
        test_list.clear_undo ();
        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);
        test_list.append_task (test_task_3);

        // Simulate drag and drop reorder
        test_list.append_task (test_task_1);
        test_list.remove_task (new Gtk.TreePath.from_string ("0"));
        assert (test_list.size == 3);

        test_list.undo ();
        assert (test_list.size == 3);
    }

    public void test_copy () {
        TaskList list_copy = test_list.copy ();
        assert (list_copy.size == 0);

        test_list.append_task (test_task_1);
        test_list.append_task (test_task_2);
        test_list.append_task (test_task_3);
        assert (test_list.size == 3);

        list_copy = test_list.copy ();
        assert (list_copy.size == 3);
        assert (test_list.contains (test_task_3.id));

        Gtk.TreePath path = new Gtk.TreePath.from_string ("2");
        assert (test_list.remove_task (path));
        assert (!test_list.contains (test_task_3.id));
    }

    public void test_load_tasks () {
        Agenda.Task[] tasks = {
            test_task_1,
            test_task_2,
            test_task_3
        };
        test_list.load_tasks (tasks);

        assert (test_list.size == 3);
        assert (test_list.contains (test_task_1.id));
    }
}

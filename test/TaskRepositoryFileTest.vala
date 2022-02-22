/***

    Copyright (C) 2014-2022 Agenda Developers

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

public class TaskRepositoryFileTest : Gee.TestCase {

    private GLib.File task_file;
    private Agenda.TaskRepositoryFile repo;
    private Agenda.Task task1;
    private Agenda.Task task2;

    public static void main (string[] args) {
        Test.init (ref args);

        TestSuite.get_root ().add_suite (new TaskRepositoryFileTest ().get_suite ());

        Test.run ();
    }

    public TaskRepositoryFileTest () {
        base ("Task");
        add_test ("redo_add", redo_add);
        add_test ("redo_remove", redo_remove);
        add_test ("redo_update", redo_update);
        add_test ("undo_add", undo_add);
        add_test ("undo_remove", undo_remove);
        add_test ("undo_update", undo_update);
        add_test ("undo_after_undo", undo_after_undo);
    }

    public override void set_up () {
        GLib.FileIOStream file_ios;

        try {
            task_file = GLib.File.new_tmp (null, out file_ios);
        } catch (Error e) {
            error ("%s", e.message);
        }

        repo = new Agenda.TaskRepositoryFile (task_file);

        task1 = new Agenda.Task.with_attributes ("0", false, "Task 1");
        task2 = new Agenda.Task.with_attributes ("1", false, "Task 2");
    }

    public override void tear_down () {
        task2 = null;
        task1 = null;
        repo = null;
        task_file = null;
    }

    public void redo_add () {
        repo.add (task1);
        repo.undo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 0);

        repo.redo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);
    }

    public void redo_remove () {
        repo.add (task1);
        repo.remove (task1);
        repo.undo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);

        repo.redo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 0);
    }

    public void redo_update () {
        repo.add (task1);
        repo.update (0, task2);
        repo.undo ();

        var undid_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (undid_task, task1));

        repo.redo ();
        undid_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (undid_task, task2));

        repo.undo ();
        undid_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (undid_task, task1));
    }

    public void undo_add () {
        repo.add (task1);
        repo.add (task2);
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 2);

        repo.undo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);

        var remaining_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (task1, remaining_task));
    }

    /**
     * Make sure that you can undo, perform some actions, and the subsequent
     * undos are accurate
     */
    public void undo_after_undo () {
        repo.add (task1);    // [task1]
        repo.remove (task1); // []
        repo.undo ();        // [task1]
        repo.add (task2);    // [task1, task2]
        repo.undo ();        // [task1]

        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);

        var task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (task, task1));
    }

    public void undo_remove () {
        repo.add (task1);

        repo.remove (task1);
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 0);

        repo.undo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);
    }

    public void undo_update () {
        repo.add (task1);
        repo.update (0, task2);

        var updated_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (updated_task, task2));

        repo.undo ();
        updated_task = repo.get_by_id (0);
        assert_true (Agenda.Task.eq (updated_task, task1));
    }
}

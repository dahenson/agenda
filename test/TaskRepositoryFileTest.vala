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
    private Agenda.Task task1;
    private Agenda.Task task2;

    public static void main (string[] args) {
        Test.init (ref args);

        TestSuite.get_root ().add_suite (new TaskRepositoryFileTest ().get_suite ());

        Test.run ();
    }

    public TaskRepositoryFileTest () {
        base ("Task");
        add_test ("undo_add", undo_add);
    }

    public override void set_up () {
        GLib.FileIOStream file_ios;

        try {
            task_file = GLib.File.new_tmp (null, out file_ios);
        } catch (Error e) {
            error ("%s", e.message);
        }

        task1 = new Agenda.Task.with_attributes ("0", false, "Task 1");
        task2 = new Agenda.Task.with_attributes ("1", false, "Task 2");
    }

    public override void tear_down () {
        task_file = null;
        task1 = null;
        task2 = null;
    }

    public void undo_add () {
        var repo = new Agenda.TaskRepositoryFile (task_file);

        repo.add (task1);
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 1);

        repo.undo ();
        assert_cmpint ((int) repo.get_n_items (), CompareOperator.EQ, 0);
    }
}

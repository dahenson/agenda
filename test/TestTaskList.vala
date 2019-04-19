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

void add_task_list_tests () {
    Test.add_func ("/agenda/task_list/contains", () => {
        var list = new Agenda.TaskList ();

        assert (list.iter_n_children (null) == 0);
        assert (!list.contains ("whatever"));

        var task = list.append_task ("a task");

        assert (list.contains (task));
    });

    Test.add_func ("/agenda/task_list/append_task", () => {
        var list = new Agenda.TaskList ();
        var task1 = list.append_task ("a new task");
        var task2 = list.append_task ("another new task");

        assert (list.iter_n_children (null) == 2);
        assert (list.contains (task1));
        assert (list.contains (task2));
    });
}

void main (string[] args) {
    Test.init (ref args);
    add_task_list_tests ();
    Test.run ();
}

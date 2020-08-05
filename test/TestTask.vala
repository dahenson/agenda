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

public class TaskTests : Gee.TestCase {

    private Agenda.Task test_task;

    public TaskTests () {
        base ("Agenda");
        add_test ("[Task] test construction", test_construction);
        add_test ("[Task] test to_string", test_to_string);
    }

    public override void set_up () {
        test_task = new Agenda.Task ();
    }

    public override void tear_down () {
        test_task = null;
    }

    public void test_construction () {
        assert (test_task.id == "");
        assert (test_task.complete == false);
        assert (test_task.text == "");

        test_task = new Agenda.Task.with_attributes ("foo", true, "bar");
        assert (test_task.id == "foo");
        assert (test_task.complete == true);
        assert (test_task.text == "bar");
    }

    public void test_to_string () {
        assert (test_task.to_string () == "f," + test_task.text);
    }
}

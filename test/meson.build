test_deps = []

libtestcase = library(
    'testcase',
    files('TestCase.vala'),
    dependencies: [gobject]
)

task_test_bin = executable(
    'Task',
    files('TestTask.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    vala_args: vala_args,
    c_args: c_args,
    include_directories: libagenda_dir
)

test('Task', task_test_bin)

task_list_test_bin = executable(
    'TaskList',
    files('TestTaskList.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    vala_args: vala_args,
    c_args: c_args,
    include_directories: libagenda_dir
)

test('TaskList', task_list_test_bin)

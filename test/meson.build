test_deps = []

libtestcase = library(
    'testcase',
    files('TestCase.vala'),
    dependencies: [gobject]
)

task_test_bin = executable(
    'test-task',
    files('TestTask.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    vala_args: vala_args,
    c_args: c_args,
    include_directories: libagenda_dir
)

task_list_test_bin = executable(
    'test-task-list',
    files('TestTaskList.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    vala_args: vala_args,
    c_args: c_args,
    include_directories: libagenda_dir
)

task_list_history_test_bin = executable(
    'test-task-list-history',
    files('TestTaskListHistory.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    vala_args: vala_args,
    c_args: c_args,
    include_directories: libagenda_dir
)

test('test-task', task_test_bin)
test('test-task-list', task_list_test_bin)
# test('test-task-list-history', task_list_history_test_bin)

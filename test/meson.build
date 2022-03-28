test_deps = []

libtestcase = library(
    'testcase',
    files('TestCase.vala'),
    dependencies: [gobject]
)

task_test = executable(
    'TaskTest',
    files('TaskTest.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    include_directories: libagenda_dir
)

task_repository_file_test = executable(
    'TaskRepositoryFileTest',
    files('TaskRepositoryFileTest.vala'),
    dependencies: libagenda_deps,
    link_with: [libtestcase, libagenda],
    include_directories: libagenda_dir
)

test('TaskRepositoryFileTest', task_repository_file_test)
test('TaskTest', task_test)


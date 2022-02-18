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

test('TaskTest', task_test)


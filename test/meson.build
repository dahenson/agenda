agenda_test_sources = files(
    'TestTaskList.vala',
)

agenda_test_bin = executable('test-agenda',
    agenda_test_sources + agenda_lib_sources,
    dependencies: agenda_deps,
    vala_args: vala_args,
    c_args: c_args,
)

test('agenda-tests', agenda_test_bin)

test_source = files(
    'TestCase.vala',
    'TestTaskList.vala',
    'TestAction.vala',
    'TestActionList.vala',
    'TestMain.vala'
)

test_bin = executable('test-agenda',
    test_source + agenda_model_sources,
    dependencies: agenda_deps,
    vala_args: vala_args,
    c_args: c_args,
)

test('test-agenda', test_bin)

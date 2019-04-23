task_list_test_bin = executable('test-agenda',
    files('TestTaskList.vala') + agenda_model_sources,
    dependencies: agenda_deps,
    vala_args: vala_args,
    c_args: c_args,
)

action_test_bin = executable('test-action',
    files('TestAction.vala') + agenda_model_sources,
    dependencies: agenda_deps,
    vala_args: vala_args,
    c_args: c_args,
)

action_list_test_bin = executable('test-action-list',
    files('TestActionList.vala') + agenda_model_sources,
    dependencies: agenda_deps,
    vala_args: vala_args,
    c_args: c_args,
)

test('task-list-tests', task_list_test_bin)
test('action-tests', action_test_bin)
test('action-list-tests', action_list_test_bin)

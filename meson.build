project('com.github.dahenson.agenda', ['vala', 'c'],
    version: '1.0.12'
)

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PKGDATADIR', join_paths(get_option('datadir'), meson.project_name()))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

vala_args = [
    '--pkg', 'config'
]

c_args = [
    '-include', 'config.h'
]

agenda_model_sources = files(
    'src/Models/HistoryList.vala',
    'src/Models/TaskList.vala',
    'src/Models/TaskListHistory.vala',
)

agenda_client_sources = files(
    'src/Agenda.vala',
    'src/Utils.vala',
    'src/Window.vala',
    'src/Widgets/TaskView.vala',
)

# dependencies
glib = dependency('glib-2.0')
gtk = dependency('gtk+-3.0')
granite = dependency('granite')

agenda_deps = [
    glib,
    gtk,
    granite
]

executable(
    meson.project_name(),
    agenda_client_sources + agenda_model_sources,
    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: agenda_deps,
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
subdir('test')

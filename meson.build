project('com.github.dahenson.agenda', ['vala', 'c'],
    version: '1.2.1',
    meson_version: '>= 0.59.0'
)

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/com.github.dahenson.agenda.gresources.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PKGDATADIR', join_paths(get_option('datadir'), meson.project_name()))
conf.set_quoted('PREFIX', get_option('prefix'))
conf.set_quoted('APPNAME', meson.project_name())
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
    'src/Models/Task.vala',
    'src/Models/TaskList.vala',
    'src/Models/TaskListHistory.vala',
)

agenda_client_sources = files(
    'src/Agenda.vala',
    'src/Window.vala',
    'src/Prefs.vala',
    'src/Widgets/TaskView.vala',
    'src/Backend/BackendInterface.vala',
    'src/Backend/FileBackend.vala',
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
    install: true
)

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true
)

subdir('data')
subdir('po')
subdir('test')

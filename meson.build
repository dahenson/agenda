project('com.github.dahenson.agenda', 'vala', 'c', version: '1.0.12')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf_data = configuration_data()
conf_data.set_quoted('PKGDATADIR', join_paths (get_option('prefix'), get_option('datadir'), meson.project_name()))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_header = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

install_data(
    'schemas/' + meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

executable(
    meson.project_name(),
    asresources,
    config_header,
    'src/Agenda.vala',
    'src/AgendaWindow.vala',
    'src/AgendaTaskList.vala',
    'src/Translations.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('granite', version: '>=0.3.0'),
        dependency('gtk+-3.0', version: '>=3.16')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')

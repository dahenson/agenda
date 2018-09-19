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
conf.set_quoted('DATADIR', get_option('datadir'))
conf.set_quoted('PKGDATADIR', join_paths(get_option('datadir'), meson.project_name()))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

vala_args = [
    '--pkg', 'config'
]

c_args = [
  '-include', 'config.h'
]

executable(
    meson.project_name(),
    'src/Agenda.vala',
    'src/AgendaTaskList.vala',
    'src/AgendaWindow.vala',
    'src/Translations.vala',
    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: [
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('granite')
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')

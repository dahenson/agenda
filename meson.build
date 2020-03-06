# Project name, programming language and version
project (
    'com.github.dahenson.agenda',
    'vala', 'c',
    version: '1.1.0'
)

# GNOME module
gnome = import ('gnome')

# Translation module
i18n = import ('i18n')

# Compiling resources
asresources = gnome.compile_resources (
    'as-resources',
    'data/' + meson.project_name () + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Project arguments
add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name ()),
    language: 'c'
)

add_project_arguments (
    ['--vapidir',
    join_paths (meson.current_source_dir (), 'vapi')],
    language: 'vala'
)

conf = configuration_data ()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name ())
conf.set_quoted('VERSION', meson.project_version ())
conf.set_quoted('PKGDATADIR', join_paths (get_option ('datadir'), meson.project_name ()))
configure_file (output: 'config.h', configuration: conf)
config_h_dir = include_directories ('.')

vala_args = [
    '--pkg', 'config'
]

c_args = [
    '-include', 'config.h'
]

# Listing dependencies
dependencies = [
    dependency ('glib-2.0'),
    dependency ('gtk+-3.0'),
    dependency ('granite')
]

subdir ('src')

executable (
    meson.project_name (),
    client_sources + model_sources,    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: dependencies,
    install : true
)

subdir ('data')
subdir ('po')
subdir ('test')

meson.add_install_script ('meson/post_install.py')

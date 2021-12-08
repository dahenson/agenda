agenda_sources = files(
    'Agenda.vala',
    'Window.vala',
    'TaskBox.vala',
    'TaskRow.vala',
)

executable(
    'agenda', # meson.project_name(),
    agenda_sources,
    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: [glib, gtk, granite],
    link_with: libagenda,
    include_directories: libagenda_dir
)

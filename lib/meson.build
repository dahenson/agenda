
libagenda_dir = include_directories('.')

libagenda_deps = [
    glib,
    gtk,
    gee,
]

libagenda_sources = files(
    'HistoryList.vala',
    'Task.vala',
    'TaskList.vala',
    'TaskListHistory.vala',
)

libagenda = library(
    'agenda',
    libagenda_sources,
    dependencies: libagenda_deps
)

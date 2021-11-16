
libagenda_dir = include_directories('.')

libagenda_deps = [
    gio,
    gee,
]

libagenda_sources = files(
    'Task.vala',
    'TaskList.vala',
    'ITaskRepository.vala',
    'TaskRepositoryFile.vala',
)

libagenda = library(
    'agenda',
    libagenda_sources,
    dependencies: libagenda_deps
)

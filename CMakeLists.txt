project (com.github.dahenson.agenda)
cmake_minimum_required (VERSION 2.8)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

#
# Base
#
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/com.github.dahenson.agenda")
set (GETTEXT_PACKAGE "com.github.dahenson.agenda")
set (RELEASE_NAME "Piece of paper.")
set (VERSION "1.0.8")
set (VERSION_INFO "Production")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

#
# Niceties
#
set (ARCHIVE_NAME agenda-${VERSION})
add_custom_target (dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target (distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install -DGSETTINGS_LOCALINSTALL=ON .. -DCMAKE_MODULE_PATH=/usr/share/cmake
    && make -j8
    && make -j8 install
    && make check
)
add_dependencies (distcheck dist)

add_custom_target (uninstall "${CMAKE_COMMAND}" -P
    "${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake")

#
# config.h
#
configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)

#
# i18n
#
add_subdirectory(po)

#
# dconf
#
add_subdirectory(schemas)

#
# Agenda
#
find_package(PkgConfig)

pkg_check_modules(DEPS REQUIRED
        gtk+-3.0>=3.16
        granite>=0.3.0
        glib-2.0>=2.39)

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)

include(ValaVersion)
ensure_vala_version("0.28.0" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C
        src/Agenda.vala
        src/AgendaWindow.vala
        src/Translations.vala
PACKAGES
        gtk+-3.0
        granite
        glib-2.0
CUSTOM_VAPIS
        vapi/config.vapi
OPTIONS
        --thread
)

add_definitions(${CFLAGS} -Wall -Winit-self -Wwrite-strings -Wunreachable-code -Wstrict-prototypes)
add_executable(com.github.dahenson.agenda ${VALA_C})

install (TARGETS com.github.dahenson.agenda RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.dahenson.agenda.desktop DESTINATION share/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.dahenson.agenda.appdata.xml DESTINATION share/appdata)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/16x16/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/24/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/24x24/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/com.github.dahenson.agenda.svg DESTINATION share/icons/hicolor/128x128/apps)

option (ICON_UPDATE "Run gtk-update-icon-cache after the install." ON)
if (ICON_UPDATE)
  install (CODE "message(\"-- Updating icon cache...\")")
  install (CODE "execute_process(COMMAND gtk-update-icon-cache -f -t ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)")
endif (ICON_UPDATE)

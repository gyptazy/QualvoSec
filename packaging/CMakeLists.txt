cmake_minimum_required(VERSION 3.16)
project(QualvoSec VERSION 1.0)

install(PROGRAMS ../src/client/qualvosec DESTINATION /sbin)
install(FILES ../src/client/qualvosec.conf DESTINATION /etc/qualvosec)
install(FILES ../sudoers.d/qualvosec DESTINATION /etc/sudoers.d)
install(FILES ../systemd/qualvosec.service DESTINATION /etc/systemd/system)

# General
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/../LICENSE")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/../README.md")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Florian Paul Azim <gyptazy> Hoberg <gyptazy@gyptazy.ch>")
set(CPACK_PACKAGE_CONTACT "Florian Paul Azim Hoberg <gyptazy@gyptazy.ch)")
set(CPACK_PACKAGE_VENDOR "gyptazy")

# RPM packaging
set(CPACK_PACKAGE_VERSION ${CMAKE_PROJECT_VERSION})
set(CPACK_GENERATOR "RPM")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_PACKAGE_NAME "qualvosec")
set(CPACK_RPM_PACKAGE_SUMMARY "qualvosec - A minimal security patch management tool.")
set(CPACK_RPM_PACKAGE_DESCRIPTION "qualvosec - A minimal security patch management tool.")
set(CPACK_RPM_CHANGELOG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/rpm_changelog.txt")
set(CPACK_PACKAGE_RELEASE 1)
set(CPACK_RPM_PACKAGE_LICENSE "GPL 3.0")
set(CPACK_RPM_PACKAGE_REQUIRES "python >= 3.2.0, python3-pyyaml, sudo")

# DEB packaging
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
set(CPACK_DEBIAN_PACKAGE_SUMMARY "qualvosec - A minimal security patch management tool.")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION "qualvosec - A minimal security patch management tool.")
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/deb_changelog.txt")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "python3-yaml, sudo")
set(CPACK_DEBIAN_PACKAGE_LICENSE "GPL 3.0")


# Install
set(CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_CURRENT_SOURCE_DIR}/postinst")
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/postinst")
include(CPack)

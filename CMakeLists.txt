cmake_minimum_required (VERSION 3.21)

project (Geoflow-bundle VERSION 2024.03.08)

option(GF_BUILD_GUI "Build the GUI components of geoflow" TRUE)
add_subdirectory(geoflow)

set(GF_PLUGIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/cmake/gf_plugin.cpp.in)
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/src
  ${CMAKE_CURRENT_BINARY_DIR}/include
)

add_subdirectory(plugins/gfp-basic3d)
add_subdirectory(plugins/gfp-building-reconstruction)
add_subdirectory(plugins/gfp-gdal)
add_subdirectory(plugins/gfp-las)
add_subdirectory(plugins/gfp-val3dity)

# install flowchart file
install(FILES flowcharts/gfc-brecon/single/reconstruct.json DESTINATION share/geoflow/gfc-brecon/single/)

# install shortcut script for building reconstruction
if (WIN32)
  string(REPLACE "/" "\\" CMAKE_INSTALL_PREFIX_WINSLASH ${CMAKE_INSTALL_PREFIX})
  configure_file(cmake/lod22-reconstruct.bat.in ${CMAKE_BINARY_DIR}/lod22-reconstruct.bat)
  install(PROGRAMS ${CMAKE_BINARY_DIR}/lod22-reconstruct.bat DESTINATION bin)
else()
  configure_file(cmake/lod22-reconstruct.sh.in ${CMAKE_BINARY_DIR}/lod22-reconstruct.sh)
  install(PROGRAMS ${CMAKE_BINARY_DIR}/lod22-reconstruct.sh DESTINATION bin RENAME lod22-reconstruct)
endif(WIN32)

if (GF_BUILD_GUI)
  set(CPACK_PACKAGE_NAME "Geoflow")
else ()
  set(CPACK_PACKAGE_NAME "Geoflow-cli")
endif (GF_BUILD_GUI)
set(CPACK_PACKAGE_VENDOR "3DGI")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Geoflow - Software")
set(CPACK_PACKAGE_VERSION ${CMAKE_PROJECT_VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${CMAKE_PPROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CMAKE_PPROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CMAKE_PPROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Geoflow")
set(CPACK_PACKAGE_DESCRIPTION "Geoflow is a geospatial 3D ETL tool.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/geoflow3d/geoflow-bundle")
# set(CPACK_RESOURCE_FILE_WELCOME "{CMAKE_SOURCE_DIR}/geoflow/LICENSE")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/geoflow/LICENSE")
set(CPACK_MONOLITHIC_INSTALL TRUE)
if (GF_BUILD_GUI)
  set(CPACK_PACKAGE_EXECUTABLES "geoflow;Geoflow")
  SET(CPACK_CREATE_DESKTOP_LINKS "geoflow" )
endif (GF_BUILD_GUI)
set(CPACK_THREADS 0)

if (WIN32)
  set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/nsis ${CMAKE_MODULE_PATH})
  set(CPACK_GENERATOR NSIS)
  set(CPACK_NSIS_MODIFY_PATH ON)
  # set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
  set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/geoflow/apps/resources/geoflow.ico")
  if (GF_BUILD_GUI)
    set(CPACK_NSIS_INSTALLED_ICON_NAME bin\\\\geoflow.exe)
  endif (GF_BUILD_GUI)
  include(InstallRequiredSystemLibraries)

  INSTALL(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION bin COMPONENT Libraries)
endif (WIN32)

INCLUDE(CPack)
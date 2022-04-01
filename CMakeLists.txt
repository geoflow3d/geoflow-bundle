cmake_minimum_required (VERSION 3.21)

project (Geoflow-bundle VERSION 2022.04.01)

add_subdirectory(geoflow)

set(GF_PLUGIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/cmake/gf_plugin.cpp.in)
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/src
  ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/thirdparty/json/include
  ${CMAKE_CURRENT_BINARY_DIR}/include
)

add_subdirectory(plugins/gfp-basic3d)
add_subdirectory(plugins/gfp-building-reconstruction)
add_subdirectory(plugins/gfp-gdal)
add_subdirectory(plugins/gfp-las)
add_subdirectory(plugins/gfp-val3dity)

set(CPACK_PACKAGE_NAME "Geoflow")
set(CPACK_PACKAGE_VENDOR "3DGI")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Geoflow - Software")
set(CPACK_PACKAGE_VERSION "2022.04.01")
set(CPACK_PACKAGE_VERSION_MAJOR "2022")
set(CPACK_PACKAGE_VERSION_MINOR "04")
set(CPACK_PACKAGE_VERSION_PATCH "22")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Geoflow")
set(CPACK_PACKAGE_DESCRIPTION "Geoflow is a geospatial 3D ETL tool.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/geoflow3d/geoflow-bundle")
# set(CPACK_RESOURCE_FILE_WELCOME "{CMAKE_SOURCE_DIR}/geoflow/LICENSE")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/geoflow/COPYING")
set(CPACK_MONOLITHIC_INSTALL TRUE)
set(CPACK_PACKAGE_EXECUTABLES "geoflow;Geoflow")
SET(CPACK_CREATE_DESKTOP_LINKS "geoflow" )
set(CPACK_THREADS 0)

if (WIN32)
  set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/nsis ${CMAKE_MODULE_PATH})
  set(CPACK_GENERATOR NSIS)
  set(CPACK_NSIS_MODIFY_PATH ON)
  # set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
  set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/geoflow/apps/resources/geoflow.ico")
  set(CPACK_NSIS_INSTALLED_ICON_NAME bin\\\\geoflow.exe)
  include(InstallRequiredSystemLibraries)

  INSTALL(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION bin COMPONENT Libraries)
endif (WIN32)

INCLUDE(CPack)
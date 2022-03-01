cmake_minimum_required (VERSION 3.21)

project (Geoflow-bundle VERSION 22.2.1)
# find_package(LASlib REQUIRED)
add_subdirectory(geoflow)

set(GF_PLUGIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/cmake/gf_plugin.cpp.in)
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/src
  ${CMAKE_CURRENT_SOURCE_DIR}/geoflow/thirdparty/json/include
  ${CMAKE_CURRENT_BINARY_DIR}/include
)
# add_definitions(-DGF_SHADER_PATH=\"share\"${GF_SHH_FILE})

add_subdirectory(plugins/gfp-basic3d)
add_subdirectory(plugins/gfp-building-reconstruction)
add_subdirectory(plugins/gfp-gdal)
add_subdirectory(plugins/gfp-las)
add_subdirectory(plugins/gfp-val3dity)

if (WIN32)
  set(CPACK_GENERATOR NSIS)
  set(CPACK_NSIS_MODIFY_PATH ON)
  include(InstallRequiredSystemLibraries)
  INSTALL(FILES ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS} DESTINATION bin COMPONENT Libraries)
endif (WIN32)
set(CPACK_PACKAGE_NAME "Geoflow")
set(CPACK_PACKAGE_VENDOR "Ravi Peters")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Geoflow - Software")
set(CPACK_PACKAGE_VERSION "22.2.1")
set(CPACK_PACKAGE_VERSION_MAJOR "22")
set(CPACK_PACKAGE_VERSION_MINOR "2")
set(CPACK_PACKAGE_VERSION_PATCH "1")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Geoflow")

INCLUDE(CPack)
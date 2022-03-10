if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET} AND NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "The vcpkg triplet")
endif()
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
            CACHE STRING "")
endif()

cmake_minimum_required(VERSION 3.14)
project (test-gdal VERSION 0.0.1)

#find_package(geoflow REQUIRED)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/" ${CMAKE_MODULE_PATH})
# GEOS include first for overriding gdal included GEOS
find_package( GEOS )
if (GEOS_FOUND)
    include_directories(${GEOS_INCLUDE_DIR})
endif()

# GDAL
find_package( GDAL )
include_directories(${GDAL_INCLUDE_DIR})

set(GF_PLUGIN_NAME ${PROJECT_NAME})
set(GF_PLUGIN_TARGET_NAME "test_gdal")

add_library(test_gdal SHARED library.cpp)

target_link_libraries( test_gdal
        ${GEOS_LIBRARY}
        ${GDAL_LIBRARY}
        )
if (MSVC)
    target_compile_options(test_gdal PRIVATE "/Zc:__cplusplus")
endif()
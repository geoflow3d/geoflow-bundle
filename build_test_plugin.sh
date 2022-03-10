#!/bin/bash

# !!! For Windows builds, the environment variables VCPKG_DEFAULT_TRIPLET and CMAKE_TOOLCHAIN_FILE need to be set so
# that CMake can pick them up automatically. !!!

# root directory of this repository
ROOT_DIR=`pwd`

# where to install geoflow (and also where dependencies can be found)
# we need to have write permissions!
if [[ "$OSTYPE" == "msys" ]]; then
  INSTALL_PREFIX=D:/opt
else
  INSTALL_PREFIX=/opt
fi

# where to put the geoflow plugin files
# we need to have write permissions!
if [[ "$OSTYPE" == "msys" ]]; then
  GF_PLUGIN_FOLDER=D:/opt/geoflow-plugins
else
  GF_PLUGIN_FOLDER=/opt/geoflow-plugins
fi

# how many parallel threads to use for building
N_PARALLEL=`getconf _NPROCESSORS_ONLN`

# exit on error of any command
set -e
# show commands
set -x

# update git modules
cd $ROOT_DIR

# create necesary directories if needed
mkdir -p $INSTALL_PREFIX
mkdir -p "$GF_PLUGIN_FOLDER"

# build and install geoflow and plugins
mkdir -p "$ROOT_DIR"/geoflow/build
cd $ROOT_DIR/geoflow/build
cmake .. \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
 -DGF_PLUGIN_FOLDER=$GF_PLUGIN_FOLDER \
 -DGF_BUILD_GUI=OFF \
 -DCMAKE_BUILD_TYPE=Release \
 -DVCPKG_DEFAULT_TRIPLET=$VCPKG_DEFAULT_TRIPLET \
 -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
cmake --build . --parallel $N_PARALLEL --config Release --target install

mkdir -p "$ROOT_DIR"/plugins/gfp-gdal/build
cd "$ROOT_DIR"/plugins/gfp-gdal/build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
  -DCMAKE_PREFIX_PATH=$INSTALL_PREFIX \
  -DVCPKG_DEFAULT_TRIPLET=$VCPKG_DEFAULT_TRIPLET \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
cmake --build . --parallel $N_PARALLEL --config Release
ls "$ROOT_DIR"/plugins/gfp-gdal/build
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  cp gfp_gdal.so $GF_PLUGIN_FOLDER
elif [[ "$OSTYPE" == "darwin"* ]]; then
  cp gfp_gdal.so $GF_PLUGIN_FOLDER
elif [[ "$OSTYPE" == "msys" ]]; then
  echo "Lightweight shell and GNU utilities compiled for Windows (part of MinGW)"
  mkdir -p "$GF_PLUGIN_FOLDER"/gfp-gdal/deps
  mkdir -p "$GF_PLUGIN_FOLDER"/gfp-gdal/gdal-data
  mkdir -p "$GF_PLUGIN_FOLDER"/gfp-gdal/proj-data
  cp Release/gfp_gdal.dll "$GF_PLUGIN_FOLDER"/gfp-gdal/
  cp "$VCPKG_ROOT"/packages/gdal_x64-windows/share/gdal/* "$GF_PLUGIN_FOLDER"/gfp-gdal/gdal-data/
  cp "$VCPKG_ROOT"/packages/proj4_x64-windows/share/proj4/* "$GF_PLUGIN_FOLDER"/gfp-gdal/proj-data/
  cp "$VCPKG_ROOT"/packages/gdal_x64-windows/bin/*.dll "$GF_PLUGIN_FOLDER"/gfp-gdal/deps/
  cp "$VCPKG_ROOT"/packages/geos_x64-windows/bin/geos_c.dll "$GF_PLUGIN_FOLDER"/gfp-gdal/deps/
  cp "$VCPKG_ROOT"/packages/geos_x64-windows/bin/geos.dll "$GF_PLUGIN_FOLDER"/gfp-gdal/deps/
fi

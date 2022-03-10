#!/bin/bash

# root directory of this repository
ROOT_DIR=`pwd`

# where to install geoflow (and also where dependencies can be found)
# we need to have write permissions!
INSTALL_PREFIX=/opt

# where to put the geoflow plugin files
# we need to have write permissions!
GF_PLUGIN_FOLDER=/opt/geoflow-plugins

# how many parallel threads to use for building
N_PARALLEL=`getconf _NPROCESSORS_ONLN`

# exit on error of any command
set -e
# show commands
set -x

# update git modules
cd $ROOT_DIR

mkdir --parents "$GF_PLUGIN_FOLDER"

echo "root dir $ROOT_DIR"
echo "plugins dir $GF_PLUGIN_FOLDER"
echo "parallel: $N_PARALLEL"
echo "ostype $OSTYPE"

echo "vcpkg install root $VCPKG_INSTALLATION_ROOT"
mkdir -p "$VCPKG_INSTALLATION_ROOT"/bla/tosz


echo "cmake_toolchain_file $CMAKE_TOOLCHAIN_FILE"
echo "vcpkg triplet $VCPKG_DEFAULT_TRIPLET"

$VCPKG_ROOT/vcpkg.exe list
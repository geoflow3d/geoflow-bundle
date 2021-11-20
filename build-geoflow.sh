#!/bin/zsh

# external folder in the 3dbag-tools repository
EXTERNAL_DIR=/home/rypeters/git/3dbag-tools/external

# where to install geoflow (and also where dependencies can be found)
# we need to have write permissions!
INSTALL_PREFIX=/opt

# where to put the geoflow plugin files
# we need to have write permissions!
GF_PLUGIN_FOLDER=/opt/geoflow-plugins

# how many parallel threads to use for building
N_PARALLEL=10

# exit on error of any command
set -e
# show commands
set -x

# update git modules
cd $EXTERNAL_DIR
git submodule update --init geoflow
git submodule update --init gfp-gdal
git submodule update --init gfp-val3dity
git submodule update --init gfp-building-reconstruction

# create necesary directories if needed
#mkdir -p "$GF_INSTALL_PREFIX"
mkdir -p "$GF_PLUGIN_FOLDER"

# build and install geoflow and plugins
mkdir -p "$EXTERNAL_DIR"/geoflow/build
cd $EXTERNAL_DIR/geoflow/build
cmake .. \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
 -DGF_PLUGIN_FOLDER=$GF_PLUGIN_FOLDER \
 -DGF_BUILD_GUI=OFF \
 -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel $N_PARALLEL --config Release
make install

# install GDAL
mkdir -p "$EXTERNAL_DIR"/dependencies
cd "$EXTERNAL_DIR"/dependencies
wget https://github.com/OSGeo/gdal/releases/download/v3.3.3/gdal-3.3.3.tar.gz
tar -zxvf gdal-3.3.3.tar.gz
cd gdal-3.3.3
./configure --prefix=$INSTALL_PREFIX
make -j$N_PARALLEL install

# install CGAL
cd "$EXTERNAL_DIR"/dependencies
wget https://github.com/CGAL/cgal/releases/download/v5.3/CGAL-5.3.tar.xz
tar -xf CGAL-5.3.tar.xz 
cd CGAL-5.3/
mkdir build
cd build/
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
sudo make install -j$N_PARALLEL

#install LASlib/tools
git clone https://github.com/LAStools/LAStools.git
cd LAStools/
mkdir build
cd build/
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
sudo make -j$N_PARALLEL install


mkdir -p "$EXTERNAL_DIR"/gfp-gdal/build
cd $EXTERNAL_DIR/gfp-gdal/build
cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
cmake --build . --parallel $N_PARALLEL --config Release
cp gfp_gdal.so $GF_PLUGIN_FOLDER

mkdir -p "$EXTERNAL_DIR"/gfp-val3dity/build
cd $EXTERNAL_DIR/gfp-val3dity/build
cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX
cmake --build . --parallel $N_PARALLEL --config Release
cp gfp_val3dity.so $GF_PLUGIN_FOLDER

mkdir -p "$EXTERNAL_DIR"/gfp-building-reconstruction/build
cd $EXTERNAL_DIR/gfp-building-reconstruction/build
cmake .. \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
 -DGFP_WITH_PDAL=OFF
cmake --build . --parallel $N_PARALLEL --config Release
cp gfp_buildingreconstruction.so $GF_PLUGIN_FOLDER


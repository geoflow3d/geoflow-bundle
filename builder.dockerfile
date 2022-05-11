FROM balazsdukai/geoflow-bundle-base:latest
ARG VERSION
LABEL org.opencontainers.image.authors="Balázs Dukai <balazs.dukai@3dgi.nl>"
LABEL org.opencontainers.image.vendor="3DGI"
LABEL org.opencontainers.image.title="geoflow-bundle-builder"
LABEL org.opencontainers.image.description="Builder image for building the geoflow executable with all of its plugins for building reconstruction."
LABEL org.opencontainers.image.version=$VERSION

ARG JOBS
ARG INSTALL_PREFIX="/usr/local"
ARG GF_PLUGIN_FOLDER="/usr/local/geoflow-plugins"
ARG GF_FLOWCHART_FOLDER="/usr/local/geoflow-flowcharts"
ARG root="/tmp"
ARG geoflow_dir="$root/geoflow"
ARG plugins_dir="$root/plugins"
ARG flowcharts_dir="$root/flowcharts"

RUN mkdir $GF_PLUGIN_FOLDER && \
    mkdir --parents $GF_FLOWCHART_FOLDER/gfc-lod13

COPY .git $root/.git
COPY .gitmodules $root

#
# 1 Install Geoflow
#
# Need to build geoflow in the project directory instead of a 'build' directory, because for some reason cmake takes
# the build dir as root, but it should take the project dir as root. This is not really how it should be.
COPY geoflow $geoflow_dir
RUN apk --update add --virtual .geoflow-deps \
        make \
        gcc \
        g++ \
        cmake \
        git \
        linux-headers && \
    cd $geoflow_dir && \
    git submodule update --init --recursive && \
    cmake . \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DGF_PLUGIN_FOLDER=$GF_PLUGIN_FOLDER \
        -DGF_BUILD_GUI=OFF \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build $geoflow_dir \
        --parallel $JOBS \
        --config Release && \
    make install && \
    cd ~ && \
    rm -rf $geoflow_dir && \
    rm -rf /user/local/man && \
    geof --help

#
# 2 Plugin: GDAL
#
COPY plugins/gfp-gdal $plugins_dir/gfp-gdal
RUN apk --update add --virtual .gdal-deps \
        make \
        gcc \
        g++ \
        cmake \
        git \
        linux-headers && \
    cd $plugins_dir/gfp-gdal && \
    git submodule update --init --recursive && \
    mkdir $plugins_dir/gfp-gdal/build && \
    cd $plugins_dir/gfp-gdal/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build . \
        --parallel $JOBS \
        --config Release && \
    cp gfp_gdal.so $GF_PLUGIN_FOLDER && \
    cd ~ && \
    rm -rf $plugins_dir/gfp-gdal && \
    rm -rf /user/local/man

#
# 3 Plugin: val3dity
#
COPY plugins/gfp-val3dity $plugins_dir/gfp-val3dity
RUN apk --update add --virtual .val3dity-deps \
        gmp-dev \
        mpfr-dev \
        eigen-dev \
        make \
        gcc \
        g++ \
        cmake \
        git \
        linux-headers && \
    cd $plugins_dir/gfp-val3dity && \
    git submodule update --init --recursive && \
    mkdir $plugins_dir/gfp-val3dity/build && \
    cd $plugins_dir/gfp-val3dity/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build . \
        --parallel $JOBS \
        --config Release && \
    cp gfp_val3dity.so $GF_PLUGIN_FOLDER && \
    cd ~ && \
    rm -rf $plugins_dir/gfp-val3dity && \
    rm -rf /user/local/man

#
# 4 Plugin: basic3d
#
COPY plugins/gfp-basic3d $plugins_dir/gfp-basic3d
RUN apk --update add --virtual .basic3d-deps \
        make \
        gcc \
        g++ \
        cmake \
        git \
        linux-headers && \
    cd $plugins_dir/gfp-basic3d && \
    git submodule update --init --recursive && \
    mkdir $plugins_dir/gfp-basic3d/build && \
    cd $plugins_dir/gfp-basic3d/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build . \
        --parallel $JOBS \
        --config Release && \
    cp gfp_core_io.so $GF_PLUGIN_FOLDER && \
    cd ~ && \
    rm -rf $plugins_dir/gfp-basic3d && \
    rm -rf /user/local/man

#
# 5 Plugin: building-reconstruction
#
COPY plugins/gfp-building-reconstruction $plugins_dir/gfp-building-reconstruction
RUN apk --update add --virtual .building-reconstruction-deps \
        gmp-dev \
        mpfr-dev \
        eigen-dev \
        make \
        gcc \
        g++ \
        cmake \
        git \
        linux-headers && \
    cd $plugins_dir/gfp-building-reconstruction && \
    git submodule update --init --recursive && \
    mkdir $plugins_dir/gfp-building-reconstruction/build && \
    cd $plugins_dir/gfp-building-reconstruction/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release \
        -DGFP_WITH_PDAL=OFF \
        -DGFP_WITH_LOD2=OFF && \
    cmake \
        --build . \
        --parallel $JOBS \
        --config Release && \
    cp gfp_buildingreconstruction.so $GF_PLUGIN_FOLDER && \
    cd ~ && \
    rm -rf $plugins_dir/gfp-building-reconstruction && \
    rm -rf /user/local/man

#
# 6 Plugin: LAS
#
COPY plugins/gfp-las $plugins_dir/gfp-las
RUN cd $plugins_dir/gfp-las && \
    git submodule update --init --recursive && \
    mkdir $plugins_dir/gfp-las/build && \
    cd $plugins_dir/gfp-las/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build . \
        --parallel $JOBS \
        --config Release && \
    cp gfp_las.so $GF_PLUGIN_FOLDER && \
    cd ~ && \
    rm -rf $plugins_dir/gfp-las && \
    rm -rf /user/local/man

# Debug dependencies
RUN apk add gdb

#
# Clean up
#

#RUN apk del .building-reconstruction-deps && \
#    apk del .basic3d-deps && \
#    apk del .val3dity-deps && \
#    apk del .gdal-deps && \
#    apk del .geoflow-deps

RUN rm -rf /tmp && \
    mkdir /tmp && \
    chmod 1777 /tmp
# Needed for stripping the image
RUN apk --update add bash

#
# Export the dependencies
#
RUN mkdir /export
COPY strip-docker-image-export /tmp
RUN bash /tmp/strip-docker-image-export \
    -v \
    -d /export \
    -f /usr/local/share/proj/proj.db \
    -f /usr/local/bin/geof \
    -f /usr/local/geoflow-plugins/gfp_buildingreconstruction.so \
    -f /usr/local/geoflow-plugins/gfp_core_io.so \
    -f /usr/local/geoflow-plugins/gfp_gdal.so \
    -f /usr/local/geoflow-plugins/gfp_val3dity.so \
    -f /usr/local/geoflow-plugins/gfp_las.so
RUN mkdir --parents "/export/usr/local/geoflow-flowcharts/gfc-lod13" "/export/usr/local/geoflow-flowcharts/gfc-lod22"
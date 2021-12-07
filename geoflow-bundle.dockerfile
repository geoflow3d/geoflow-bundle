FROM geoflow3d/geoflow-bundle-base:latest
LABEL org.opencontainers.image.authors="b.dukai@tudelft.nl"
LABEL maintainer.email="b.dukai@tudelft.nl" maintainer.name="Balázs Dukai"
LABEL description="Builder image for building the geoflow-bundle"

ARG JOBS
ARG INSTALL_PREFIX="/usr/local"
ARG GF_PLUGIN_FOLDER="/usr/local/geoflow-plugins"
ARG root="/tmp"
ARG geoflow_dir="$root/geoflow"
ARG plugins_dir="$root/plugins"

RUN mkdir $GF_PLUGIN_FOLDER

COPY .git $root/.git
COPY .gitmodules $root

#
# 1 Install Geoflow
#
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
    mkdir $geoflow_dir/build && \
    cd $geoflow_dir/build && \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DGF_PLUGIN_FOLDER=$GF_PLUGIN_FOLDER \
        -DGF_BUILD_GUI=OFF \
        -DCMAKE_BUILD_TYPE=Release && \
    cmake \
        --build $geoflow_dir/build \
        --parallel $JOBS \
        --config Release && \
    make install && \
    cd ~ && \
    apk del .geoflow-deps && \
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
    apk del .gdal-deps && \
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
    apk del .val3dity-deps && \
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
    apk del .basic3d-deps && \
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
    apk del .building-reconstruction-deps && \
    rm -rf $plugins_dir/gfp-building-reconstruction && \
    rm -rf /user/local/man \

# Clean up
RUN rm -rf /tmp && \
    mkdir /tmp && \
    chmod 1777 /tmp
# Needed for stripping the image
RUN apk add bash

ENTRYPOINT ["/usr/local/bin/geof"]

CMD ["--help"]
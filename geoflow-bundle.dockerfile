FROM geoflow3d/geoflow-bundle-base:latest
LABEL org.opencontainers.image.authors="b.dukai@tudelft.nl"
LABEL maintainer.email="b.dukai@tudelft.nl" maintainer.name="Balázs Dukai"
LABEL description="Builder image for building the geoflow-bundle"

ARG JOBS
ARG INSTALL_PREFIX="/usr/local"
ARG GF_PLUGIN_FOLDER="/usr/local/geoflow-plugins"

COPY . /tmp
ARG geoflow_dir="/tmp/geoflow"
ARG plugins_dir="/tmp/plugins"
RUN mkdir $GF_PLUGIN_FOLDER

#
# 1 Install Geoflow
#
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
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
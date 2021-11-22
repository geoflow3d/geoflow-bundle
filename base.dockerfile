FROM alpine:3.15
# See for additional annotations: https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="b.dukai@tudelft.nl"
LABEL maintainer.email="b.dukai@tudelft.nl" maintainer.name="Balázs Dukai"
LABEL description="Base image for building the geoflow-bundle"
#LABEL org.name="3D Geoinformation Research Group, Delft University of Technology, Netherlands" org.website="https://3d.bk.tudelft.nl/"
#LABEL website="http://tudelft3d.github.io/3dfier"
#LABEL version="1.3"

#
# 1 Install proj
#
ARG PROJ_VERSION=8.1.1
RUN apk --update add sqlite libstdc++ sqlite-libs libgcc && \
    apk --update add --virtual .proj-deps \
        make \
        gcc \
        g++ \
        file \
        sqlite-dev \
        unzip && \
    cd /tmp && \
    wget http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz && \
    tar xfvz proj-${PROJ_VERSION}.tar.gz && \
    rm -f proj-${PROJ_VERSION}.tar.gz && \
    cd proj-${PROJ_VERSION} && \
    ./configure \
      --disable-tiff \
      --without-curl \
      --enable-lto && \
    make && \
    make install && \
    echo "Entering root folder" && \
    cd / &&\
    echo "Cleaning dependencies tmp and manuals" && \
    apk del .proj-deps && \
    rm -rf /tmp/* && \
    rm -rf /user/local/man && \
    for i in /usr/local/lib/libproj*; do strip -s $i 2>/dev/null || /bin/true; done && \
    for i in /usr/local/lib/geod*; do strip -s $i 2>/dev/null || /bin/true; done && \
    for i in /usr/local/bin/proj*; do strip -s $i 2>/dev/null || /bin/true; done && \
    proj

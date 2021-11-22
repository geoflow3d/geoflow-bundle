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
# proj-data is not added, TIFF and curl support are disabled, because we are not going to do any
# transformations with proj, just need it for the gis libraries to run.
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
      --enable-lto \
      CFLAGS="-O3" CXXFLAGS="-O3" && \
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

#
# 2 Install geos
#
ARG GEOS_VERSION=3.10.1
RUN apk --update add --virtual .geos-deps \
        make \
        gcc \
        g++ \
        cmake \
        file \
        libtool && \
    cd /tmp && \
    wget http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 && \
    tar xfvj geos-${GEOS_VERSION}.tar.bz2 && \
    rm -f geos-${GEOS_VERSION}.tar.bz2 && \
    cd geos-${GEOS_VERSION} && \
    mkdir "_build" && \
    cd "_build" && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_DOCUMENTATION=OFF \
        .. && \
    make && \
    ctest && \
    make install && \
    cd ~ && \
    apk del .geos-deps && \
    rm -rf /tmp/* && \
    rm -rf /user/local/man && \
    for i in /usr/local/lib/libgeos*; do strip -s $i 2>/dev/null || /bin/true; done && \
    for i in /usr/local/bin/geos-config*; do strip -s $i 2>/dev/null || /bin/true; done

#
# 3 Install Boost
#
ARG BOOST_VERSION=1_77_0
RUN apk add boost-dev && \
    apk --update add \
        zlib \
        zstd \
        xz \
        icu \
        bzip2 \
        mpfr-dev \
        eigen && \
    apk --update add --virtual .boost-deps \
        zlib-dev \
        zstd-dev \
        xz-dev \
        icu-dev \
        bzip2-dev \
        make \
        gcc \
        g++ \
        cmake \
        linux-headers && \
    cd /tmp && \
    wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_${BOOST_VERSION}.tar.bz2 && \
    tar xzfj boost_${BOOST_VERSION}.tar.bz2 && \
    cd boost_${BOOST_VERSION} && \
    ./bootstrap.sh \
        --with-libraries=all \
        --libdir=/usr/local/lib \
        --includedir=/usr/local/include \
        --exec-prefix=/usr/local && \
    ./b2 \
        --libdir=/usr/local/lib \
        --includedir=/usr/local/include \
        --exec-prefix=/usr/local \
        install && \
    cd ~ && \
    apk del .boost-deps && \
    rm -rf /tmp/* && \
    rm -rf /user/local/man && \
    for i in /usr/local/lib/libboost*; do strip -s $i 2>/dev/null || /bin/true; done

#
# 4 Install LASTools
#
ARG LASTOOLS_VERSION=9ecb4e682153436b044adaeb3b4bfdf556109a0f
RUN apk --update add --virtual .lastools-deps \
        which \
        make \
        cmake \
        gcc \
        g++ \
        file \
        git \
        libtool && \
    cd /tmp && \
    git clone https://github.com/LAStools/LAStools.git lastools && \
    cd lastools && \
    git checkout ${LASTOOLS_VERSION} && \
    mkdir "_build" && \
    cd "_build" && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    apk del .lastools-deps && \
    rm -rf /tmp/* && \
    rm -rf /user/local/man

#
# 5 Install CGAL
#
ARG CGAL_VERSION=5.3
RUN apk --update add \
        gmp \
        mpfr-dev \
        eigen \
        zlib && \
    apk --update add --virtual .cgal-deps \
        make \
        gcc \
        gmp-dev \
        mpfr-dev \
        eigen-dev \
        zlib-dev \
        g++ \
        git \
        cmake \
        linux-headers && \
    cd /tmp && \
    wget https://github.com/CGAL/cgal/releases/download/v${CGAL_VERSION}/CGAL-${CGAL_VERSION}.tar.xz && \
    tar xf CGAL-${CGAL_VERSION}.tar.xz && \
    cd CGAL-${CGAL_VERSION} && \
    mkdir build && \
    cd build && \
    cmake \
        -DBoost_NO_BOOST_CMAKE=TRUE \
        -DBoost_NO_SYSTEM_PATHS=TRUE \
        -DBOOST_ROOT=/usr/local \
        -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd ~ && \
    apk del .cgal-deps && \
    rm -rf /tmp/* && \
    rm -rf /user/local/man && \
    for i in /usr/local/lib64/libCGAL*; do strip -s $i 2>/dev/null || /bin/true; done

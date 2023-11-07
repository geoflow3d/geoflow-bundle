FROM ubuntu:lunar-20230301
ARG VERSION
LABEL org.opencontainers.image.authors="Balázs Dukai <balazs.dukai@3dgi.nl>"
LABEL org.opencontainers.image.vendor="3DGI"
LABEL org.opencontainers.image.title="geoflow-bundle-base-ubuntu"
LABEL org.opencontainers.image.description="Base image for building the geoflow-bundle."
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.licenses="MIT"
ARG JOBS

RUN apt-get update && apt-get -y install \
    libgeos++-dev \
    libeigen3-dev \
    libpq-dev \
    nlohmann-json3-dev \
    libboost-filesystem-dev \
    libsqlite3-dev sqlite3\
    libgeotiff-dev \
    build-essential \
    wget \
    git \
    cmake

RUN cd /tmp && \
    wget https://download.osgeo.org/proj/proj-9.1.0.tar.gz && \
    tar -zxvf proj-9.1.0.tar.gz  && \
    cd proj-9.1.0 && \
    mkdir build && \
    cd build/ && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && \
    cmake --build . --config Release --parallel $JOBS && \
    cmake --install . && \
    rm -rf /tmp/*

ARG LASTOOLS_VERSION=9ecb4e682153436b044adaeb3b4bfdf556109a0f
RUN cd /tmp && \
    git clone https://github.com/LAStools/LAStools.git lastools && \
    cd lastools && \
    git checkout ${LASTOOLS_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel $JOBS --config Release && \
    cmake --install . && \
    rm -rf /tmp/* && \
    mkdir /tmp/geoflow-bundle

ARG CGAL_VERSION=5.5
RUN cd /tmp && \
    apt-get install -y libboost-system-dev libboost-thread-dev libgmp-dev libmpfr-dev zlib1g-dev && \
    wget https://github.com/CGAL/cgal/releases/download/v${CGAL_VERSION}/CGAL-${CGAL_VERSION}.tar.xz && \
    tar xf CGAL-${CGAL_VERSION}.tar.xz && \
    cd CGAL-${CGAL_VERSION} && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . --parallel $JOBS --config Release && \
    cmake --install . && \
    rm -rf /tmp/*

ARG FGDB_VERSION=1.5.2
ARG GDAL_VERSION=3.7.3
RUN cd /tmp && \
    apt-get install -y libexpat-dev && \
    git clone https://github.com/Esri/file-geodatabase-api.git && \
    tar -xf file-geodatabase-api/FileGDB_API_${FGDB_VERSION}/FileGDB_API-RHEL7-64gcc83.tar.gz && \
    rm -rf /tmp/FileGDB_API-RHEL7-64gcc83/lib/libstdc++.so* && \
    mv /tmp/FileGDB_API-RHEL7-64gcc83 /usr/local/src/FileGDB && \
    ln -s /usr/local/src/FileGDB/lib/libFileGDBAPI.so /usr/local/lib/libFileGDBAPI.so && \
    ln -s /usr/local/src/FileGDB/lib/libfgdbunixrtl.so /usr/local/lib/libfgdbunixrtl.so && \
    ldconfig && \
    wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz && \
    tar -zxvf gdal-${GDAL_VERSION}.tar.gz && \
    cd gdal-${GDAL_VERSION} && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_IPO=OFF -DFileGDB_ROOT=/usr/local/src/FileGDB -DBUILD_TESTING=OFF && \
    cmake --build . --parallel $JOBS --config Release && \
    cmake --install . && \
    ldconfig && \
    rm -rf /tmp/*

RUN ldconfig

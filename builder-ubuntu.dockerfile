FROM balazsdukai/geoflow-bundle-base-ubuntu:kinetic
ARG VERSION
LABEL org.opencontainers.image.authors="Balázs Dukai <balazs.dukai@3dgi.nl>"
LABEL org.opencontainers.image.vendor="3DGI"
LABEL org.opencontainers.image.title="geoflow-bundle-builder-ubuntu"
LABEL org.opencontainers.image.description="Builder image for building the geoflow executable with all of its plugins for building reconstruction."
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.licenses="MIT"

ARG JOBS
ARG geoflow_src="/usr/src/geoflow-bundle"
# Because explicit is better than defaults
ARG GF_PLUGIN_FOLDER="/usr/local/lib/geoflow-plugins"

# Debug dependencies and need bash for stripping the image
RUN apt-get install -y gdb bash

# Only copy what's needed for the build so the docker image build is faster
COPY ./cmake $geoflow_src/cmake
COPY ./flowcharts $geoflow_src/flowcharts
COPY ./geoflow $geoflow_src/geoflow
COPY ./plugins $geoflow_src/plugins
COPY ./CMakeLists.txt ./strip-docker-image-export $geoflow_src/

# Need to explicitly create the plugin directory
RUN chmod 1777 $geoflow_src && \
    cd $geoflow_src && \
    mkdir -p $GF_PLUGIN_FOLDER && \
    mkdir -p build && cd build && \
    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DGF_BUILD_GUI=OFF \
      -DGF_PLUGIN_FOLDER=$GF_PLUGIN_FOLDER && \
    cmake --build . --parallel $JOBS --config Release
# Split the install from the build, because it makes easier to debug installation issues
RUN cd $geoflow_src/build && cmake --install .
# Do not clean up $geoflow_src here, so that the build cache is not invalidated unless
# the files have really changed.

# Check geoflow
RUN echo $(geof -p)

# So that CLion can install the cmake target when run in a docker container, because
# CLion maps the host UID as the container user
RUN chmod -R a+w $GF_PLUGIN_FOLDER

#
# Export the dependencies
#
# maybe needs all transformation files from /usr/local/share/proj/ ?
# maybe needs the pkgconfig files for gdal and proj from /usr/local/lib/pkgconfig/ ?
RUN mkdir /export && \
    bash $geoflow_src/strip-docker-image-export \
    -v \
    -d /export \
    -f /usr/local/share/proj/proj.db \
    -f /usr/local/bin/geof \
    -f $GF_PLUGIN_FOLDER/gfp_buildingreconstruction.so \
    -f $GF_PLUGIN_FOLDER/gfp_core_io.so \
    -f $GF_PLUGIN_FOLDER/gfp_gdal.so \
    -f $GF_PLUGIN_FOLDER/gfp_val3dity.so \
    -f $GF_PLUGIN_FOLDER/gfp_las.so
RUN mkdir --parents "/export/usr/local/geoflow-flowcharts/gfc-lod13" "/export/usr/local/geoflow-flowcharts/gfc-brecon"

ARG UID=1000
RUN useradd -m -u ${UID} -s /bin/bash builder
USER builder
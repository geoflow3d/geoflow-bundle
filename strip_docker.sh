#!/bin/bash

# From https://github.com/balazsdukai/strip-docker-image
strip-docker-image -v \
  -i geoflow3d/geoflow-bundle:latest \
  -t geoflow3d/geoflow-bundle:stripped \
  -f /usr/local/bin/geof \
  -f /usr/local/geoflow-plugins/gfp_buildingreconstruction.so \
  -f /usr/local/geoflow-plugins/gfp_core_io.so \
  -f /usr/local/geoflow-plugins/gfp_gdal.so \
  -f /usr/local/geoflow-plugins/gfp_val3dity.so
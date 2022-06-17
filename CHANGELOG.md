# 2022.06.17

I am excited to release the first public version of Geoflow-bundle!
Geoflow is a spatial ETL tool for processing 3D geo-information such as point clouds and 3D city models.
Geoflow-bundle as it is today bundles the Geoflow software with the essential geoflow plugins and flowcharts for LoD2.2 building reconstruction.
It has been several years in the making and I am really excited to share this work as open source software and I really hope people will find it useful.

With this first public release we have aimed to simplify things as much as possible so that it becomes easy to install and use the Geoflow-bundle package.
Over time and as we further improve and extend the software and we will make more features available to you.
But we start off simple with a tool `lod22-reconstruct` that performs LoD2.2 (and LoD1.2, LoD1.3) reconstruction for a single building.
See the [README](https://github.com/geoflow3d/geoflow-bundle#readme) for more details on how to use it.

Release 2022.06.17 is available as a windows installer or a docker image.

- Ravi Peters

## Most important changes

+ New reconstruction flowchart that is simple and easy to use
+ New tool `lod22-reconstruct` that makes it as easy as possible to get started with building reconstruction
+ New command line interface with new features such as printing a list of available globals for flowchart and turning of verbose messages (by default)
+ Improved error handling
+ fix OGR writer to be able to output both to PostgreSQL and GPKG and other supported formats
+ Output writers are not executed if output filename/connection string is left empty (makes it easy to omit certain output formats)
+ Fix multiple bugs

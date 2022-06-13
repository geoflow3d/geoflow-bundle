# Automated 3D building reconstruction from point clouds

![3D model from point cloud](docs/img/pc_to_model.png)

*A tool for reconstructing 3D building models from point clouds, fully automated, with high-detail. Free and open-source.*

## What does it do?

+ Takes a point cloud and 2D building polygon and generates a 3D model of the building. It is a fully automated process, there is no manual intervention.
+ It is possible to tweak the reconstruction parameters to adjust it a little to different input data qualities.
+ Outputs a model as a simple extrusion, in LoD1.2, LoD1.3, LoD2.2. See [the refined Levef of Details by the 3D geoinformation research group ](https://3d.bk.tudelft.nl/lod/).
+ For LoD2.2, it generates the model with as much detail in the roof structure as there is in the point cloud.
+ For LoD2.2, it generates the required [Semantics](https://www.cityjson.org/specs/1.1.1/#semantics-of-geometric-primitives) for the surfaces.
+ It writes to Wavefront OBJ, GeoPackage, CityJSON and a PostgreSQL database.

## Requirements on the input data

### Point cloud

+ Acquired through aerial scanning, either Lidar or Dense Image Matching. But Lidar is preferred, because it is often of higher quality. Thus point clouds of building facades from mobile mapping surveys are not supported.
+ The fewer outliers the better. Here is where Lidar point clouds outperform those from DiM, because the latter often results in "wobbly" surfaces.
+ Classified, with at least a *ground* and a *building* class.
+ Has sufficient point density. We achieve good results with 8-10 pts/m2 in the [3D BAG](https://3dbag.nl).
+ Well aligned with the 2D building polygon.
+ It is cropped to the extent of the 2D building polygon. It is okay to leave some buffer.
+ In `.LAS` or `.LAZ` format.

### 2D building polygon

+ A simple 2D polygon.
+ Preferably roofprint, since the input point cloud was also acquired from the air.
+ Well aligned with the point cloud.
+ In GeoPackage or ESRI Shapefile format, or a PostGIS database connection.

## Repository structure

This repository is a collection of components that form the software that does the building reconstruction.
The components are added as git submodules, and they are parts, plugins of the *geoflow* software. You can read more about geoflow in the Wiki of this repository.

## Installation

It will probably be easiest to use one of the binary packages on the Release page (docker, windows installer) as explained below. Only in case you want to compile the software from scratch you need to clone this repository with all of its submodules, eg. use the command:

```
$ git clone --recurse-submodules https://github.com/geoflow3d/geoflow-bundle.git
```

### Running with Docker (TO UPDATE AFTER NEW EXE)

The building reconstruction tool for LoD1.3 models is packaged into a docker image, `geoflow3d/lod13tool`.
An example command to run the reconstruction in a new container from the image and write the results to a database on the host:

```shell
docker run \
  --rm \
  --network=host \
  -v /my/dir/data:/data/in_out_data \
  geoflow3d/lod13tool:latest \
  -c config.toml
```

### Running on windows (TO UPDATE AFTER NEW EXE)
* Download the latest installer from the [Release page](https://github.com/geoflow3d/geoflow-bundle/releases), eg `Geoflow-2022.03.22-win64.exe`.
* Run the installer.
* Launch Geoflow from the start menu. You can now load flowcharts eg the one for [LoD1.3 building reconstruction](https://github.com/geoflow3d/gfc-lod13)

## Usage

Two things are needed for running the reconstruction on some input data.
1. A *flowchart* that contains the logic of the reconstruction and describes how the various components (plugins and nodes) connect. The *flowchart* is a JSON file.
2. The *geoflow* executable (`geof`), which runs (`run`) the logic in flowchart.

```shell
geof run flowchart.json
```

Use `geof --help` to see the help message of each command.

```shell
Geoflow
Usage: /opt/geoflow/bin/geof [OPTIONS] [SUBCOMMAND]

Options:
  -h,--help                   Print this help message and exit
  --verbose                   Print verbose messages
[Option Group: Info]
  Debug information
  Options:
    -v,--version                Print version information
    -p,--plugins                List available plugins
    -n,--nodes                  List available nodes from plugins that are loaded

Subcommands:
  run                         Load and run flowchart
  set                         Set flowchart globals (comes after run)
```

### Globals

A flowchart can contain some parameters that are set for the whole flowchart. These are called *globals*
To see the global parameters of a flowchart and their explanation pass the `--globals` option to the `run` subcommand.
```shell
geof run flowchart.json --globals
```
An example of the flowchart globals printed by `--globals`:
```shell
Available globals:
 > building_identifier [Unique identifier attribute present in input footprint source]
   default value: "fid"
 > input_footprint [Input 2D vector file with building footprint(s)]
   default value: "test-data/wippolder.gpkg"
 > input_footprint_select [Feature number to load (value must be in the range 1 to number of features in foootprint input)]
   default value: 1
...
```

You can set the value of one or more flowchart global parameters from the commandline with the `set` command.
For instance, set the `building_identifier` and `input_footprint` parameters.

```shell
geof run flowchart.json set --input_footprint=/some/path/file.gpkg --building_identifier=gid
```

Alternatively, you can also set the global paramters in a TOML configuration file.

```toml
# contents of config.toml
input_footprint=/bla/file.gpkg
building_identifier=gid
```

```shell
geof run flowchart.json set --config config.toml
```

#### Order of priority

It is possible to set the global parameters in three different places and their order of priority is as follows:

1. parameters passed in the command line with `set`
2. parameters set in a TOML configuration file
3. parameters stored in the flowchart

Thus, a parameter set with `set` has the highest priority and overrides the value set in any other location.

### Building reconstruction

The flowchart of the building reconstruction is in ...

## Citation 

If you use the software in scientific publications, please see CITATION.cff
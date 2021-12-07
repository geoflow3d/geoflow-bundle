# Bundle of geoflow components for building reconstruction

This repository collects geoflow with all its components that are needed for building reconstruction.
The components (geoflow, plugins and flowcharts) are added as git submodules.

Note that some of the components might not be available to you, depending on your access rights to its repository.

To clone this repository with all of its submodules use the command:

```
$ git clone --recurse-submodules https://github.com/geoflow3d/geoflow-bundle.git
```

## Running with Docker

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
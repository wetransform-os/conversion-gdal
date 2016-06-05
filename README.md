conversion-gdal
===============

[![Docker Hub Badge](https://img.shields.io/badge/Docker-Hub%20Hosted-blue.svg)](https://hub.docker.com/r/wetransform/conversion-gdal/)

Docker image for format conversion based on GDAL/OGR.

The image is meant to be used for one-off `docker run` commands running a specific conversion task.
The script `./ogr-convert.sh` in the working directory should be called when running a container.
The default command prints the script usage.

Example calls
-------------

Convert remote file, result is stored in internal container volume:

```
docker run -it wetransform/conversion-gdal:latest ./ogr-convert.sh --source http://static.wetransform.to/examples/gml/inspire-hy-p.gml --target-name inspire-hy-p.shp -f "ESRI Shapefile"
```

Convert remote file, result is stored in mounted folder as current user:

```
docker run -it --user=$(id -u):$(id -g) -v $(pwd):/data wetransform/conversion-gdal:latest ./ogr-convert.sh --source http://static.wetransform.to/examples/gml/inspire-hy-p.gml --target-dir /data --target-name inspire-hy-p.json -f "GeoJson"
```

Similarly, files from mounted volumes can be converted as well, by providing a file path resolvable in the container instead of a remote (http/https) location.

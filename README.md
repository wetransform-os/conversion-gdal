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
docker run -it wetransform/conversion-gdal:latest ./ogr-convert.sh --source https://wetransform.box.com/shared/static/2fe8kbl6psu3ul2bth3uqymx2chlwkdc.gml --target-name hydroEx.shp -f "ESRI Shapefile"
```

Convert remote file, result is stored in mounted folder as current user:

```
docker run -it --user=$(id -u):$(id -g) -v $(pwd):/data wetransform/conversion-gdal:latest ./ogr-convert.sh --source https://wetransform.box.com/shared/static/2fe8kbl6psu3ul2bth3uqymx2chlwkdc.gml --target-dir /data --target-name hydroEx.json -f "GeoJson"
```

Similarly, files from mounted volumes can be converted as well, by providing a file path resolvable in the container instead of a remote (http/https) location.

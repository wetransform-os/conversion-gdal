## 1.0.0 (2025-02-06)

### Features

* add helper script for running gdal_translate ([7299ce4](https://github.com/wetransform-os/conversion-gdal/commit/7299ce4ff11ad1a1f2bb41c8d4a25fe9ff08c007)), closes [ING-1380](https://wetransform.atlassian.net/browse/ING-1380)
* add open option FORCE_SRS_DETECTION in case of gml files and if source_srs is not set ([c134c29](https://github.com/wetransform-os/conversion-gdal/commit/c134c2986922b00440b66473acf1ed5613baf277)), closes [ING-4473](https://wetransform.atlassian.net/browse/ING-4473)
* add second version of translate script ([10bac64](https://github.com/wetransform-os/conversion-gdal/commit/10bac64b2143529dbad289ceca48e9e27d8f323f)), closes [ING-1530](https://wetransform.atlassian.net/browse/ING-1530)
* create overviews for translated GeoTiff images ([d6e5002](https://github.com/wetransform-os/conversion-gdal/commit/d6e50022d6193f07abd039676edf8d29edff19c0)), closes [ING-3308](https://wetransform.atlassian.net/browse/ING-3308)
* special case handling for GeoTiff w/ single Grayscale band ([7f36eae](https://github.com/wetransform-os/conversion-gdal/commit/7f36eaee7580407faf0856b4d9d064aca1e343d3)), closes [ING-2008](https://wetransform.atlassian.net/browse/ING-2008)
* support custom arguments for OGR translation script ([b59413b](https://github.com/wetransform-os/conversion-gdal/commit/b59413bdb07d9c26e4d58d65eb31e88bb7a0d393)), closes [ING-2671](https://wetransform.atlassian.net/browse/ING-2671)
* support file URIs for local files ([b55b4db](https://github.com/wetransform-os/conversion-gdal/commit/b55b4dbb84830972067a58f478b21e5ece9f5102)), closes [ING-3068](https://wetransform.atlassian.net/browse/ING-3068)
* support world parameter in translate script ([2b57442](https://github.com/wetransform-os/conversion-gdal/commit/2b57442c7a73c7801bdf01fea03c2dd2923f558d)), closes [ING-1461](https://wetransform.atlassian.net/browse/ING-1461)

### Bug Fixes

* correctly recognize NoData values in metadata ([4d8de9e](https://github.com/wetransform-os/conversion-gdal/commit/4d8de9e377ad02492d59306f99ef07837a43a84a)), closes [ING-1903](https://wetransform.atlassian.net/browse/ING-1903)
* improve detection of NoData values ([f1a165b](https://github.com/wetransform-os/conversion-gdal/commit/f1a165bce47fd29410f03317b334aefd4aafa3c6))
* prevent failing conversion from GML to GPKG ([6675408](https://github.com/wetransform-os/conversion-gdal/commit/66754080b9dabfcd6c03a1d43eba9d717ff5be8b)), closes [ING-1747](https://wetransform.atlassian.net/browse/ING-1747)

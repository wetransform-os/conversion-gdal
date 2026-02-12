## [1.1.3](https://github.com/wetransform-os/conversion-gdal/compare/v1.1.2...v1.1.3) (2026-02-12)

### Bug Fixes

* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.12.0 ([ee75cd6](https://github.com/wetransform-os/conversion-gdal/commit/ee75cd68daf2253f75c0ccc685a800cfe48d1c9d))
* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.12.1 ([84338c4](https://github.com/wetransform-os/conversion-gdal/commit/84338c4d44893bb376282443bdcd90e9d4561b56))
* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.12.2 ([9564578](https://github.com/wetransform-os/conversion-gdal/commit/95645780842aeb8abfc55329f04004a82e63642b))

## [1.1.2](https://github.com/wetransform-os/conversion-gdal/compare/v1.1.1...v1.1.2) (2025-09-16)

### Bug Fixes

* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.11.4 ([f7379fc](https://github.com/wetransform-os/conversion-gdal/commit/f7379fc2637053bf802b32a6c9530f5c99ab05e6))

## [1.1.1](https://github.com/wetransform-os/conversion-gdal/compare/v1.1.0...v1.1.1) (2025-07-21)

### Bug Fixes

* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.11.0 ([2c16f65](https://github.com/wetransform-os/conversion-gdal/commit/2c16f65b886ed6c87799685415c0ce6e9f760524))
* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.11.3 ([8a5c4e8](https://github.com/wetransform-os/conversion-gdal/commit/8a5c4e89db13bf02ef0c692f57f9b54c70978bf3))

## [1.1.0](https://github.com/wetransform-os/conversion-gdal/compare/v1.0.0...v1.1.0) (2025-05-08)

### Features

* support extracting source files in nested Zip files ([87f6c50](https://github.com/wetransform-os/conversion-gdal/commit/87f6c503ea9e2182bda00d913a3acba6d85d6c76)), closes [ING-4619](https://wetransform.atlassian.net/browse/ING-4619)

### Bug Fixes

* **deps:** update dependency org.apache.groovy:groovy-json to v4.0.26 ([22657c6](https://github.com/wetransform-os/conversion-gdal/commit/22657c6a244bb23827afc6c7836688d10bddddc2))
* **deps:** update dependency org.junit.jupiter:junit-jupiter to v5.12.0 ([6ad1bf8](https://github.com/wetransform-os/conversion-gdal/commit/6ad1bf8d4e1058387573fd371c8f8a8d62a21ac0))
* **deps:** update dependency org.junit.jupiter:junit-jupiter to v5.12.1 ([1568ee6](https://github.com/wetransform-os/conversion-gdal/commit/1568ee6ac98de2f0c5c25b1e672307729b7e2ea8))
* **deps:** update dependency org.junit.jupiter:junit-jupiter to v5.12.2 ([ac3039b](https://github.com/wetransform-os/conversion-gdal/commit/ac3039b9f2e0f04727755cc90c6bff775f158ac8))
* **deps:** update dependency org.slf4j:slf4j-simple to v2.0.17 ([ed1ed29](https://github.com/wetransform-os/conversion-gdal/commit/ed1ed296321717c7a1f4e37039987e53eec34801))
* **deps:** update dependency org.testcontainers:junit-jupiter to v1.20.5 ([6c9fa1a](https://github.com/wetransform-os/conversion-gdal/commit/6c9fa1a07a1073cb77df446239d6ba6b4ae541b1))
* **deps:** update dependency org.testcontainers:junit-jupiter to v1.20.6 ([00877c5](https://github.com/wetransform-os/conversion-gdal/commit/00877c5b80a275ffd3f6c5e8365ac1e2339085d2))
* **deps:** update dependency org.testcontainers:junit-jupiter to v1.21.0 ([68647c2](https://github.com/wetransform-os/conversion-gdal/commit/68647c210fd4be027e1491dd875c2b01072866ce))
* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.10.2 ([6e0d87f](https://github.com/wetransform-os/conversion-gdal/commit/6e0d87fa4c2544fe091a4f87f95878fae010422a))
* **deps:** update ghcr.io/osgeo/gdal docker tag to ubuntu-small-3.10.3 ([e8c9f65](https://github.com/wetransform-os/conversion-gdal/commit/e8c9f658cf8d96d6cb80c1c25d5c8e86be91d64f))

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

/*
 * Copyright (c) 2025 wetransform GmbH
 * All rights reserved.
 */
import groovy.json.JsonSlurper

class JsonHelper {

  static void verifyGeoJsonFeatureCollection(File jsonFile, int expectedFeatures) {
    def json = new JsonSlurper().parse(jsonFile)
    assert json.type == 'FeatureCollection'
    def size = json.features.size()
    assert size == expectedFeatures
  }
}

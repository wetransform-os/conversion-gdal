/*
 * Copyright (c) 2025 wetransform GmbH
 * All rights reserved.
 */
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.function.Consumer;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.BindMode;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.shaded.org.apache.commons.io.FileUtils;
import org.testcontainers.utility.DockerImageName;

public class ConversionTest {

  private static final Logger log = LoggerFactory.getLogger(ConversionTest.class);

  @Test
  public void testConvertGmlToGeojson() throws UnsupportedOperationException, IOException, InterruptedException {
    runConversion("hydroEx.gml", "hydroxEx.json", "GeoJSON", file -> {
      // simple verification by checking the number of features
      JsonHelper.verifyGeoJsonFeatureCollection(file, 982);
    });
  }

  @Test
  public void testConvertZippedShapeToGeojson()
    throws UnsupportedOperationException, IOException, InterruptedException {
    runConversion("shapefile_ikg.zip", "ikg.json", "GeoJSON", file -> {
      // simple verification by checking the number of features
      JsonHelper.verifyGeoJsonFeatureCollection(file, 14);
    });
  }

  @Test
  public void testConvertNestedZippedShapeToGeojson()
    throws UnsupportedOperationException, IOException, InterruptedException {
    runConversion("nested_shapefile_ikg.zip", "ikg.json", "GeoJSON", file -> {
      // simple verification by checking the number of features
      JsonHelper.verifyGeoJsonFeatureCollection(file, 14);
    });
  }

  private void runConversion(String sourceClasspathResource, String targetName, String targetFormat,
    Consumer<File> verify) throws UnsupportedOperationException, IOException, InterruptedException {
    // extract file name from classpath resource
    String sourceFileName = sourceClasspathResource.substring(sourceClasspathResource.lastIndexOf("/") + 1);

    // serve file with nginx testcontainers container
    try (Network network = Network.newNetwork();
      GenericContainer<?> nginx = new GenericContainer<>(DockerImageName.parse("nginx:latest"))
        .withClasspathResourceMapping(sourceClasspathResource, "/usr/share/nginx/html/" + sourceFileName,
          BindMode.READ_ONLY)
        .withNetwork(network)
        .withNetworkAliases("nginx")) {

      nginx.start();

      // get file URL
      String fileUrl = "http://nginx/" + sourceFileName;
      var targetDir = "/opt/data";

      // build command array
      String[] cmd = new String[]{"./ogr-convert.sh", "--source", fileUrl, "--target-dir", targetDir, "--target-name",
          targetName, "-f", targetFormat};

      // run conversion
      try (GenericContainer<?> conversionContainer = new GenericContainer<>(
        DockerImageName.parse("wetransform/conversion-gdal:test"))
        .withNetwork(network)
        .withCommand(cmd)
        .withLogConsumer(new Slf4jLogConsumer(log).withPrefix("gdal"))) {

        conversionContainer.start();

        // conversionContainer.followOutput(outputFrame -> {
        // System.out.print(outputFrame.getUtf8String());
        // });

        // wait for container to finish
        while (conversionContainer.isRunning()) {
          Thread.sleep(1000);
        }

        // check exit code
        var state = conversionContainer.getContainerInfo().getState();
        assertEquals(0, state.getExitCodeLong());

        // create a temp folder
        var tmpDir = Files.createTempDirectory("conversion-test");
        try {
          var targetFile = new File(tmpDir.toFile(), targetName);
          conversionContainer.copyFileFromContainer(targetDir + "/" + targetName, targetFile.getAbsolutePath());

          if (verify != null) {
            verify.accept(targetFile);
          } else {
            assertTrue(targetFile.exists());
          }
        } finally {
          // delete folder
          FileUtils.deleteDirectory(tmpDir.toFile());
        }
      }
    }
  }

}

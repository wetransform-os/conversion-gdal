/*
 * Copyright (c) 2025 wetransform GmbH
 * All rights reserved.
 */
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.BindMode;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.shaded.org.apache.commons.io.FileUtils;
import org.testcontainers.utility.DockerImageName;

public class RasterConversionTest {

  private static final Logger log = LoggerFactory.getLogger(RasterConversionTest.class);

  // Regression test: single-band grayscale source served under a generic file name
  // without a recognizable extension, which previously broke driver auto-detection
  // for translate2.sh's intermediate gdalwarp/gdal_translate steps.
  @Test
  public void testConvertSingleBandGrayscaleWithoutExtension()
    throws UnsupportedOperationException, IOException, InterruptedException {
    String sourceClasspathResource = "single-band-gray.tif";

    // serve file with nginx testcontainers container, without a recognizable extension
    try (Network network = Network.newNetwork();
      GenericContainer<?> nginx = new GenericContainer<>(DockerImageName.parse("nginx:latest"))
        .withClasspathResourceMapping(sourceClasspathResource, "/usr/share/nginx/html/source", BindMode.READ_ONLY)
        .withNetwork(network)
        .withNetworkAliases("nginx")) {

      nginx.start();

      String fileUrl = "http://nginx/source";
      var targetDir = "/opt/data";
      var targetName = "out.tif";

      // intentionally not passing --source-name, so the downloaded file has no extension
      String[] cmd = new String[]{"./translate2.sh", "--source", fileUrl, "--target-dir", targetDir, "--target-name",
          targetName, "-f", "GTiff"};

      try (GenericContainer<?> conversionContainer = new GenericContainer<>(
        DockerImageName.parse("wetransform/conversion-gdal:test"))
        .withNetwork(network)
        .withCommand(cmd)
        .withLogConsumer(new Slf4jLogConsumer(log).withPrefix("gdal"))) {

        conversionContainer.start();

        while (conversionContainer.isRunning()) {
          Thread.sleep(1000);
        }

        var state = conversionContainer.getContainerInfo().getState();
        assertEquals(0, state.getExitCodeLong());

        var tmpDir = Files.createTempDirectory("conversion-test");
        try {
          var targetFile = new File(tmpDir.toFile(), targetName);
          conversionContainer.copyFileFromContainer(targetDir + "/" + targetName, targetFile.getAbsolutePath());

          assertTrue(targetFile.exists());
          assertTrue(targetFile.length() > 0);
        } finally {
          FileUtils.deleteDirectory(tmpDir.toFile());
        }
      }
    }
  }

}

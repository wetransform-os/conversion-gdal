FROM ghcr.io/osgeo/gdal:ubuntu-small-3.11.4

# see https://github.com/OSGeo/gdal/pkgs/container/gdal

# add build info - see hooks/build and http://label-schema.org/
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.source=$VCS_URL \
  org.opencontainers.image.revision=$VCS_REF

USER root

# data directory - not using the base images volume because then the permissions cannot be adapted
ENV DATA_DIR=/opt/data

# Install needed utilities and setup folders
RUN apt-get update -y && \
  apt-get install -y zip unzip curl jq file && \
  apt-get autoremove -y && \
  apt-get clean && \
  mkdir -p /opt/convert && \
  mkdir -p /opt/data

# Add bash script helper
#ADD https://github.com/akesterson/cmdarg/raw/977badef4b6eb215c4dc970db9126387f2c9f428/cmdarg.sh /opt/convert/cmdarg.sh
ENV CMD_ARG_VERSION=977badef4b6eb215c4dc970db9126387f2c9f428
RUN curl -L "https://github.com/akesterson/cmdarg/raw/${CMD_ARG_VERSION}/cmdarg.sh" > /opt/convert/cmdarg.sh

# Add scripts
COPY ./scripts/*.sh /opt/convert/

# Fix permissions
RUN chmod -R a+rwx $DATA_DIR && \
  chmod -R a+rx /opt/convert

USER nobody

# declare volume late so permissions apply
VOLUME /opt/data

WORKDIR /opt/convert
CMD ["./ogr-convert.sh", "--help"]

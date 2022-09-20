#!/bin/bash

# This script compiles Protongraph so as to allow it to run headlessly within a docker container.
# After you have run this script, you should be able to run Protongraph by executing the following command:
#
# "docker run protongraph"
#
# To shutdown the running container, run "docker ps -a" and "docker rm -f <container_id>"

# Build the compile image for compilation
docker build -f Dockerfile.compile . -t gcc-build-coturn
# Run the compile image in order to build the required headless binary
docker run --rm -v "$PWD":/usr/coturn -w /usr/coturn gcc-build-coturn ./configure && make SHELL=/bin/bash CPPFLAGS="$CPPFLAGS -I/usr/local/ssl/include" LDFLAGS="$LDFLAGS -L/usr/local/ssl/lib"  
# Build the coturn runtime image
docker build . -t coturn

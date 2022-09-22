#!/bin/bash
# Allows us to step into a running protongraph container and launch a shell.
id=$(docker ps -a --no-trunc --filter name=^/coturn$ | grep coturn | awk '{ print $1 }')
docker exec -it $id /bin/bash
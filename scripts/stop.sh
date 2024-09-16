#!/bin/bash

id=$(docker ps -a --no-trunc --filter name=^/coturn$ | grep coturn | awk '{ print $1 }')
docker stop $id && docker rm $id
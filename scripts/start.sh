#!/bin/bash
docker run --name coturn -p 3478:3478 -p 3478:3478/udp -p 5349:5349 -p 5349:5349/udp -p 49152-50000:49152-50000/udp coturn
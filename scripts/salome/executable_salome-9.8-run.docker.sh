#!/usr/bin/env bash

# run_salome.sh
# A helper script to launch the Salome Docker container with proper host configurations

# Exit immediately if a command exits with a non-zero status
set -e

# You can override the image tag by setting SALOME_IMAGE before running this script
default_image="feelpp/salome:9.8.0-ubuntu-20.04"
SALOME_IMAGE="${SALOME_IMAGE:-$default_image}"

# Map the user's home directory inside the container
HOST_HOME_DIR="/home/$(id -un)"
CONTAINER_HOME_DIR="/home/$(id -un)"

# Run the Docker container

docker run -it \
    --net=host \
    --ipc=host \
    --pid=host \
    --privileged=true \
    --env DISPLAY="$DISPLAY" \
    --rm \
    -v "$HOST_HOME_DIR:$CONTAINER_HOME_DIR" \
    "$SALOME_IMAGE"

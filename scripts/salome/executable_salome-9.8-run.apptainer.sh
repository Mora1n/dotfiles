#!/bin/bash
apptainer run --env DISPLAY=$DISPLAY --cwd=$PWD --nv /home/morain/containers/salome-9.8.0.sif

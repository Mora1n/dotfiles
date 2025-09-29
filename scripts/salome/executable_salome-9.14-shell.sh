#!/bin/bash
export OUTPUT_PATH=$(dirname $(readlink -f "$0"))
export SALOME=${HOME}/Software/salome/SALOME-9.14.0-native-DB12-SRC/salome
python $SALOME withsession -t --ns-port-log $OUTPUT_PATH/.salomeport
python $SALOME shell

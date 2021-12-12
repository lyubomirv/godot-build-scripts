#!/bin/bash

set -e

if [ ! -z "${PRESET_GODOT_DIR}" ]; then
  cd $PRESET_GODOT_DIR
  rm -rf bin
else
  rm -rf godot
  mkdir godot
  cd godot
  tar xf /root/godot.tar.gz --strip-components=1
fi

if [ ! -z "${CUSTOM_MODULES_DIR}" ]; then
  export ADDITIONAL_SCONS_PARAMS="custom_modules=${CUSTOM_MODULES_DIR}"
fi

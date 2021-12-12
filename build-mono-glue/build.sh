#!/bin/bash

set -e

# Config

source /root/common/prep.sh

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no ${ADDITIONAL_SCONS_PARAMS}"
export OPTIONS="debug_symbols=no use_static_cpp=no"
export TERM=xterm
export DISPLAY=:0

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Building and generating Mono glue..."

  mono --version
  export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig/

  ${SCONS} platform=x11 bits=64 ${OPTIONS} target=release_debug tools=yes module_mono_enabled=yes mono_glue=no

  rm -rf /root/mono-glue/*
  xvfb-run bin/godot.x11.opt.tools.64.mono --audio-driver Dummy --generate-mono-glue /root/mono-glue || /bin/true
fi

echo "Mono glue generated successfully"

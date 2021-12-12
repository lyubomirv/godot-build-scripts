#!/bin/bash

set -e

if [ "${BUILD_TEMPLATES}" != "1" ]; then
  exit 0
fi

# Config

source /root/common/prep.sh

export SCONS="call scons -j${NUM_CORES} verbose=yes warnings=no progress=no ${ADDITIONAL_SCONS_PARAMS}"
export OPTIONS="production=yes"
export BUILD_ARCHES="x86 x64 arm"
export ANGLE_SRC_PATH='c:\angle'

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for UWP..."

  for arch in ${BUILD_ARCHES}; do
    for release in release release_debug; do
      wine cmd /c /root/build/build.bat $arch $release

      sync
      wineserver -kw

      mkdir -p /root/out/$arch
      mv bin/* /root/out/$arch
    done
  done
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "No Mono support for UWP yet."
  #cp /root/mono-glue/*.cpp modules/mono/glue/
  #cp -r /root/mono-glue/Managed/Generated modules/mono/glue/Managed/
fi

echo "UWP build successful"

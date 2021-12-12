#!/bin/bash

set -e

if [ "${BUILD_SERVER}" != "1" ]; then
  exit 0
fi

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="production=yes"
export OPTIONS_MONO="module_mono_enabled=yes mono_static=yes mono_prefix=/root/mono-installs/desktop-linux-x86_64-release"
export TERM=xterm
export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

source /root/common/prep.sh

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Server..."

  $SCONS platform=server $OPTIONS tools=yes target=release_debug
  mkdir -p /root/out/x64/tools
  cp -rvp bin/* /root/out/x64/tools
  rm -rf bin

  $SCONS platform=server $OPTIONS tools=no target=release
  mkdir -p /root/out/x64/templates
  cp -rvp bin/* /root/out/x64/templates
  rm -rf bin
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for Server..."

  cp /root/mono-glue/*.cpp modules/mono/glue/
  cp -r /root/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
  cp -r /root/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

  $SCONS platform=server $OPTIONS $OPTIONS_MONO tools=yes target=release_debug copy_mono_root=yes
  mkdir -p /root/out/x64/tools-mono
  cp -rvp bin/* /root/out/x64/tools-mono
  rm -rf bin

  $SCONS platform=server $OPTIONS $OPTIONS_MONO tools=no target=release
  mkdir -p /root/out/x64/templates-mono
  cp -rvp bin/* /root/out/x64/templates-mono
  rm -rf bin
fi

echo "Server build successful"

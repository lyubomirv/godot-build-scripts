#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="production=yes"
export OPTIONS_MONO="module_mono_enabled=yes"
export TERM=xterm

source /root/common/prep.sh

# pkg-config wrongly points to lib instead of lib64 for arch-dependent header.
sed -i ${GODOT_SDK_LINUX_X86_64}/x86_64-godot-linux-gnu/sysroot/usr/lib/pkgconfig/dbus-1.pc -e "s@/lib@/lib64@g"

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Linux..."

  export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

  if [ "${BUILD_EDITOR_x86_64}" == "1" ]; then
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS target=editor
    mkdir -p /root/out/x86_64/tools
    cp -rvp bin/* /root/out/x86_64/tools
    rm -rf bin
  fi

  if [ "${BUILD_TEMPLATES}" == "1" ]; then
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS target=template_debug
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS target=template_release
    mkdir -p /root/out/x86_64/templates
    cp -rvp bin/* /root/out/x86_64/templates
    rm -rf bin
  fi

  export PATH="${GODOT_SDK_LINUX_X86}/bin:${BASE_PATH}"

  if [ "${BUILD_EDITOR_x86}" == "1" ]; then
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS target=editor
    mkdir -p /root/out/x86_32/tools
    cp -rvp bin/* /root/out/x86_32/tools
    rm -rf bin
  fi

  if [ "${BUILD_TEMPLATES}" == "1" ]; then
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS target=template_debug
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS target=template_release
    mkdir -p /root/out/x86_32/templates
    cp -rvp bin/* /root/out/x86_32/templates
    rm -rf bin
  fi
fi

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Starting Mono build for Linux..."

  cp -r /root/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/
  cp -r /root/mono-glue/GodotSharp/GodotSharpEditor/Generated modules/mono/glue/GodotSharp/GodotSharpEditor/

  export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

  if [ "${BUILD_EDITOR_x86_64}" == 1 ]; then
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS $OPTIONS_MONO target=editor
    ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd
    mkdir -p /root/out/x86_64/tools-mono
    cp -rvp bin/* /root/out/x86_64/tools-mono
    rm -rf bin
  fi

  if [ "${BUILD_TEMPLATES}" == 1 ]; then
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS $OPTIONS_MONO target=template_debug
    $SCONS platform=linuxbsd arch=x86_64 $OPTIONS $OPTIONS_MONO target=template_release
    mkdir -p /root/out/x86_64/templates-mono
    cp -rvp bin/* /root/out/x86_64/templates-mono
    rm -rf bin
  fi

  export PATH="${GODOT_SDK_LINUX_X86}/bin:${BASE_PATH}"

  if [ "${BUILD_EDITOR_x86}" == 1 ]; then
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS $OPTIONS_MONO target=editor
    ./modules/mono/build_scripts/build_assemblies.py --godot-output-dir=./bin --godot-platform=linuxbsd
    mkdir -p /root/out/x86_32/tools-mono
    cp -rvp bin/* /root/out/x86_32/tools-mono
    rm -rf bin
  fi

  if [ "${BUILD_TEMPLATES}" == 1 ]; then
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS $OPTIONS_MONO target=template_debug
    $SCONS platform=linuxbsd arch=x86_32 $OPTIONS $OPTIONS_MONO target=template_release
    mkdir -p /root/out/x86_32/templates-mono
    cp -rvp bin/* /root/out/x86_32/templates-mono
    rm -rf bin
  fi
fi

echo "Linux build successful"

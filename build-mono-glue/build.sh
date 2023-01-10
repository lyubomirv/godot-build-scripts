#!/bin/bash

set -e

# Config

export SCONS="scons -j${NUM_CORES} verbose=yes warnings=no progress=no"
export OPTIONS="debug_symbols=no use_static_cpp=no"
export TERM=xterm
export DISPLAY=:0
export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"

source /root/common/prep.sh

# pkg-config wrongly points to lib instead of lib64 for arch-dependent header.
sed -i ${GODOT_SDK_LINUX_X86_64}/x86_64-godot-linux-gnu/sysroot/usr/lib/pkgconfig/dbus-1.pc -e "s@/lib@/lib64@g"

# Temporarily until we make --headless mode actually skip X11.
dnf install -y libX11 libXcursor libXrandr libXinerama libXi mesa-libGL

# Mono

if [ "${MONO}" == "1" ]; then
  echo "Building and generating Mono glue..."

  dotnet --info
  export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/pkgconfig/

  ${SCONS} platform=linuxbsd ${OPTIONS} target=editor module_mono_enabled=yes

  rm -rf /root/mono-glue/*
  bin/godot.linuxbsd.editor.x86_64.mono --headless --generate-mono-glue /root/mono-glue
fi

echo "Mono glue generated successfully"

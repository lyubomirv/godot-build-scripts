#!/bin/bash

set -e

# Config

source /root/common/prep.sh

if [ "${BUILD_WEB_PARALLEL}" == "1" ]; then
  # To speed up builds with single-threaded full LTO linking,
  # we run all builds in parallel each from their own folder.
  export NUM_JOBS=5
else
  export NUM_JOBS=1
fi
declare -a JOBS=(
  "target=editor use_closure_compiler=yes"
  "target=template_debug"
  "target=template_release"
  "target=template_debug dlink_enabled=yes"
  "target=template_release dlink_enabled=yes"
)

export SCONS="scons -j$(expr ${NUM_CORES} / ${NUM_JOBS}) verbose=yes warnings=no progress=no"
export OPTIONS="production=yes"
export OPTIONS_MONO="module_mono_enabled=yes -j${NUM_CORES}"
export TERM=xterm

source /root/emsdk/emsdk_env.sh

# Classical

if [ "${CLASSICAL}" == "1" ]; then
  echo "Starting classical build for Web..."

  for i in {0..4}; do
    if [[ "${JOBS[$i]}" == *"editor"* ]]; then
      if [ "${BUILD_EDITOR}" != "1" ]; then
        continue
      fi
    else
      if [ "${BUILD_TEMPLATES}" != "1" ]; then
        continue
      fi
    fi

    if [ "${BUILD_WEB_PARALLEL}" == "1" ]; then
      cp -r /root/godot /root/godot$i
      cd /root/godot$i
      echo "$SCONS platform=web ${OPTIONS} ${JOBS[$i]}"
      $SCONS platform=web ${OPTIONS} ${JOBS[$i]} &
      pids[$i]=$!
    else
      cd /root/godot
      echo "$SCONS platform=web ${OPTIONS} ${JOBS[$i]}"
      $SCONS platform=web ${OPTIONS} ${JOBS[$i]}
    fi
  done

  if [ "${BUILD_WEB_PARALLEL}" == "1" ]; then
    for pid in ${pids[*]}; do
      wait $pid
    done
  fi

  if [ "${BUILD_EDITOR}" == "1" ]; then
    mkdir -p /root/out/tools
    [[ ${BUILD_WEB_PARALLEL} = 1 ]] && godot_dir="godot0" || godot_dir="godot"
    cp -rvp /root/$godot_dir/bin/*.editor*.zip /root/out/tools
  fi

  if [ "${BUILD_TEMPLATES}" == "1" ]; then
    mkdir -p /root/out/templates
    for i in {1..4}; do
      [[ ${BUILD_WEB_PARALLEL} = 1 ]] && godot_dir="godot${i}" || godot_dir="godot"
      cp -rvp /root/$godot_dir/bin/*.zip /root/out/templates
    done
  fi
fi

# Mono

# No Web support with .NET 6 yet.
#if [ "${MONO}" == "1" ]; then
if false; then
  echo "Starting Mono build for Web..."

  cp -r /root/mono-glue/GodotSharp/GodotSharp/Generated modules/mono/glue/GodotSharp/GodotSharp/

  if [ "${BUILD_TEMPLATES}" != "1" ]; then
    $SCONS platform=web ${OPTIONS} ${OPTIONS_MONO} target=template_debug
    $SCONS platform=web ${OPTIONS} ${OPTIONS_MONO} target=template_release

    mkdir -p /root/out/templates-mono
    cp -rvp bin/*.zip /root/out/templates-mono
    rm -f bin/*.zip
  fi
fi

echo "Web build successful"

#!/usr/bin/env bash
# Local ZMK build via Docker. No host toolchain needed beyond Docker.
#
# Usage:
#   ./scripts/build.sh            # build both halves
#   ./scripts/build.sh left       # build one half
#   ./scripts/build.sh --init     # (re)create the west workspace, then build both
#
# Output: firmware/corne_{left,right}.uf2
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="${ZMK_WORKSPACE:-$HOME/zmk-workspace}"
IMAGE="zmkfirmware/zmk-build-arm:stable"

# The board name is variant-qualified (Zephyr hardware-model-v2). Plain
# "nice_nano_v2" no longer resolves on current ZMK main.
BOARD="nice_nano/nrf52840/zmk"

docker_run() {
  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$WS:/workspace" \
    -v "$REPO/config:/workspace/config" \
    -e HOME=/tmp \
    -e ZEPHYR_BASE=/workspace/zephyr \
    -e CMAKE_PREFIX_PATH=/workspace/zephyr/share \
    -w "$1" "$IMAGE" bash -c "git config --global --add safe.directory '*'; $2"
}

init_ws() {
  echo "==> Initializing west workspace at $WS (several minutes)"
  # The workspace must live OUTSIDE the repo: `west init -l` roots the
  # workspace at the manifest repo's parent, and this repo already has a
  # zephyr/ directory that west would otherwise collide with.
  mkdir -p "$WS/config"
  docker_run /workspace/config 'west init -l . && cd /workspace && west update'
}

build_half() {
  local half="$1"
  echo "==> Building corne_$half"
  docker_run /workspace/zmk/app \
    "west build -p -b $BOARD -d /workspace/build/$half -- \
       -DSHIELD=corne_$half -DZMK_CONFIG=/workspace/config"
  mkdir -p "$REPO/firmware"
  cp "$WS/build/$half/zephyr/zmk.uf2" "$REPO/firmware/corne_$half.uf2"
  echo "==> firmware/corne_$half.uf2"
}

[[ "${1:-}" == "--init" ]] && { init_ws; shift; }
[[ -d "$WS/zmk" ]] || init_ws

case "${1:-both}" in
  left)  build_half left ;;
  right) build_half right ;;
  both)  build_half left; build_half right ;;
  *) echo "usage: $0 [left|right|both] [--init]" >&2; exit 1 ;;
esac

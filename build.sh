#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cflags="$(pkg-config --cflags wayland-server wlroots)"
libs="$(pkg-config --libs wayland-server wlroots)"

clang -c "$root_dir/shim.c" -o "$root_dir/shim.o" $cflags
odin build "$root_dir" -out:"$root_dir/scumwm" -extra-linker-flags:"$root_dir/shim.o $libs"

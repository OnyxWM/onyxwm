#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

wlr_pkg="wlroots-0.19"
gen_dir="$root_dir/gen"
xdg_xml="/usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml"

mkdir -p "$gen_dir"

# Generate xdg-shell protocol sources (needed by wlroots headers)
wayland-scanner server-header "$xdg_xml" "$gen_dir/xdg-shell-protocol.h"
wayland-scanner private-code "$xdg_xml" "$gen_dir/xdg-shell-protocol.c"

cflags="$(pkg-config --cflags wayland-server "$wlr_pkg") -DWLR_USE_UNSTABLE -I$gen_dir"
libs="$(pkg-config --libs wayland-server "$wlr_pkg")"

# Compile generated protocol code
clang -c "$gen_dir/xdg-shell-protocol.c" -o "$gen_dir/xdg-shell-protocol.o" \
  $(pkg-config --cflags wayland-server)

# Compile shim (needs -Igen so xdg-shell-protocol.h can be found)
clang -c "$root_dir/shim.c" -o "$root_dir/shim.o" $cflags

# Link everything into the Odin binary
link_flags="$root_dir/shim.o $gen_dir/xdg-shell-protocol.o \
-Wl,--no-as-needed -Wl,--start-group $libs -Wl,--end-group -Wl,--as-needed"

odin build "$root_dir" \
  -out:"$root_dir/onyxwm" \
  -extra-linker-flags:"-v $link_flags"

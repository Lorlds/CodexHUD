#!/usr/bin/env bash
set -euo pipefail

prefix="${PREFIX:-$HOME/.local}"
bindir="$prefix/bin"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_mode="${CODEXHUD_INSTALL_MODE:-link}"
codexhud_home="${CODEXHUD_HOME:-$HOME/.codexhud}"

mkdir -p "$bindir"
case "$install_mode" in
  link)
    ln -sf "$repo_dir/bin/codexhud" "$bindir/codexhud"
    ;;
  copy)
    cp "$repo_dir/bin/codexhud" "$bindir/codexhud"
    cp "$repo_dir/VERSION" "$bindir/.codexhud-version"
    ;;
  *)
    printf 'install: unsupported CODEXHUD_INSTALL_MODE=%s\n' "$install_mode" >&2
    exit 2
    ;;
esac
chmod +x "$bindir/codexhud"

mkdir -p "$codexhud_home"
if [ ! -f "$codexhud_home/prices.json" ]; then
  cp "$repo_dir/config/prices.json" "$codexhud_home/prices.json"
  printf 'installed %s\n' "$codexhud_home/prices.json"
else
  printf 'kept existing %s\n' "$codexhud_home/prices.json"
fi

printf 'installed %s\n' "$bindir/codexhud"
printf 'try: CODEXHUD_STYLE=risk %s tmux\n' "$bindir/codexhud"

#!/usr/bin/env bash
set -euo pipefail

prefix="${PREFIX:-$HOME/.local}"
bindir="$prefix/bin"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_mode="${TOKENHUD_INSTALL_MODE:-${CODEXHUD_INSTALL_MODE:-link}}"
tokenhud_home="${TOKENHUD_HOME:-${CODEXHUD_HOME:-$HOME/.tokenhud}}"
legacy_codexhud_home="${CODEXHUD_HOME:-$HOME/.codexhud}"

mkdir -p "$bindir"
case "$install_mode" in
  link)
    ln -sf "$repo_dir/bin/tokenhud" "$bindir/tokenhud"
    ln -sf "$repo_dir/bin/codexhud" "$bindir/codexhud"
    ;;
  copy)
    cp "$repo_dir/bin/tokenhud" "$bindir/tokenhud"
    cp "$repo_dir/bin/codexhud" "$bindir/codexhud"
    cp "$repo_dir/VERSION" "$bindir/.tokenhud-version"
    cp "$repo_dir/VERSION" "$bindir/.codexhud-version"
    ;;
  *)
    printf 'install: unsupported TOKENHUD_INSTALL_MODE=%s\n' "$install_mode" >&2
    exit 2
    ;;
esac
chmod +x "$bindir/tokenhud"
chmod +x "$bindir/codexhud"

mkdir -p "$tokenhud_home"
if [ ! -f "$tokenhud_home/prices.json" ]; then
  if [ -f "$legacy_codexhud_home/prices.json" ]; then
    cp "$legacy_codexhud_home/prices.json" "$tokenhud_home/prices.json"
    printf 'migrated %s\n' "$tokenhud_home/prices.json"
  else
    cp "$repo_dir/config/prices.json" "$tokenhud_home/prices.json"
    printf 'installed %s\n' "$tokenhud_home/prices.json"
  fi
else
  printf 'kept existing %s\n' "$tokenhud_home/prices.json"
fi

printf 'installed %s\n' "$bindir/tokenhud"
printf 'installed %s\n' "$bindir/codexhud"
printf 'try: TOKENHUD_STYLE=risk %s tmux\n' "$bindir/tokenhud"

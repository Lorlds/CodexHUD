#!/usr/bin/env bash
set -euo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
binary="$(tmux show-option -gqv @codexhud_binary)"
[ -z "$binary" ] && binary="$current_dir/../bin/codexhud"

style="$(tmux show-option -gqv @codexhud_style)"
[ -z "$style" ] && style="balanced"

interval="$(tmux show-option -gqv @codexhud_interval)"
case "$interval" in
  *[!0-9]*) interval="" ;;
esac

existing="$(tmux show-option -gqv status-right)"
printf -v segment '#(CODEXHUD_STYLE=%q %q tmux #{q:pane_current_path})' "$style" "$binary"

[ -z "$interval" ] || tmux set-option -g status-interval "$interval" >/dev/null
case "$existing" in
  *codexhud*) ;;
  *) tmux set-option -g status-right "$segment $existing" >/dev/null ;;
esac

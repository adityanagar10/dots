#!/usr/bin/env bash
set -euo pipefail

# Bound to prefix+= as: run-shell "~/scripts/tmux-equalize.sh '#{window_id}'"
# Equalizes pane sizes without changing orientation when there are
# exactly 2 panes (tiled would happily turn a horizontal split into a
# stacked one); falls back to tiled for 3+ panes, where orientation is
# already mixed.

window_id="${1:?usage: tmux-equalize.sh <window_id>}"

pane_count=$(tmux list-panes -t "$window_id" | wc -l | tr -d ' ')

if [[ "$pane_count" -ne 2 ]]; then
  tmux select-layout -t "$window_id" tiled
  exit 0
fi

tops=$(tmux list-panes -t "$window_id" -F '#{pane_top}' | sort -u | wc -l | tr -d ' ')
if [[ "$tops" -eq 1 ]]; then
  # Both panes share the same top edge: side by side.
  tmux select-layout -t "$window_id" even-horizontal
else
  tmux select-layout -t "$window_id" even-vertical
fi

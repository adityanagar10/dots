#!/usr/bin/env bash
# Usage: claude-status.sh <window_id>
# Prints "●" (amber, via tmux style codes) if any pane in the given tmux
# window is running a `claude` process, otherwise prints nothing.
#
# colour180 approximates starship's mono_accent amber (#c9974f) more
# closely than colour214 (#ffaf00), so the tmux dot and prompt read as
# the same accent color rather than two different shades of amber.
#
# Two detection strategies are tried: pgrep for a `claude` child of the
# pane's shell (true when claude was launched via `send-keys`, e.g. by
# agent-new.sh) and a direct `ps` check on the pane's own process (true
# if claude ever runs as the pane's process directly, e.g. via `new-window
# -e` or `exec`). Both are kept since either launch style is possible.
window_id="$1"

pane_pids=$(tmux list-panes -t "$window_id" -F '#{pane_pid}' 2>/dev/null)
for pid in $pane_pids; do
  if pgrep -P "$pid" -f '^claude' >/dev/null 2>&1 || ps -p "$pid" -o command= 2>/dev/null | grep -q '^claude'; then
    printf '#[fg=colour180]●#[default]'
    exit 0
  fi
done

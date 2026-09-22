#!/usr/bin/env bash
# Usage: claude-status.sh <window_id>
# Prints a colored "●" if a Claude Code agent is running in any pane of the
# given tmux window, otherwise prints nothing. Color reflects the agent's
# actual status (busy/waiting/idle), not just "running or not":
#   busy    -> amber  (colour180, matches starship's claude-agent accent)
#   waiting -> yellow (colour220, needs your input)
#   idle    -> green  (colour114, done, your turn)
#
# Uses `claude agents --json` (Claude Code's own self-reported agent state)
# instead of scanning `ps`/`pgrep` for a `claude` process. The prior
# ps/pgrep approach couldn't distinguish busy/waiting/idle at all, and on
# some platforms a pane only exposes its parent shell's process, not the
# claude child running inside it — this sidesteps both problems by asking
# Claude Code directly. Approach adapted from craftzdog/tmux-claude-session-
# manager's agents.sh (MIT), simplified to a single window's status dot
# rather than a full cross-session picker.
window_id="$1"

agents_json=$(claude agents --json 2>/dev/null) || exit 0
[ -n "$agents_json" ] || exit 0

pane_ttys=$(tmux list-panes -t "$window_id" -F '#{pane_tty}' 2>/dev/null)
[ -n "$pane_ttys" ] || exit 0

# Build pid -> tty once, then check each agent's pid against this window's ttys.
pid_tty=$(ps -Ao pid=,tty= 2>/dev/null)

best_rank=-1
best_color=""
while IFS=$'\t' read -r pid status; do
  [ -n "$pid" ] || continue
  tty=$(printf '%s\n' "$pid_tty" | awk -v p="$pid" '$1 == p { print $2; exit }')
  [ -n "$tty" ] || continue

  matched=0
  while IFS= read -r pane_tty; do
    pane_tty="${pane_tty#/dev/}"
    [ "$pane_tty" = "$tty" ] && { matched=1; break; }
  done <<< "$pane_ttys"
  [ "$matched" -eq 1 ] || continue

  case "$status" in
    waiting) rank=2; color="colour220" ;;
    busy)    rank=1; color="colour180" ;;
    idle)    rank=0; color="colour114" ;;
    *)       continue ;;
  esac
  if [ "$rank" -gt "$best_rank" ]; then
    best_rank=$rank
    best_color=$color
  fi
done < <(printf '%s' "$agents_json" | jq -r '.[] | select(.kind == "interactive") | [.pid, .status] | @tsv' 2>/dev/null)

[ -n "$best_color" ] && printf '#[fg=%s]●#[default]' "$best_color"

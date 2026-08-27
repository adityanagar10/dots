#!/usr/bin/env bash
set -euo pipefail

# Bound to prefix+L as: run-shell "~/scripts/agent-link.sh '#{pane_current_path}'"
# Symlinks another repo's main checkout into the current agent worktree
# for read access (e.g. working on pos, need to browse loyalty's code).
# tmux expands #{pane_current_path} against the invoking pane before
# spawning this script, since a detached run-shell process has no tmux
# "current pane" of its own.

worktree_dir="${1:?usage: agent-link.sh <worktree_path>}"

repo_root=$(git -C "$worktree_dir" rev-parse --show-toplevel 2>/dev/null) || {
  tmux display-message "agent-link: not inside a git repository"
  exit 1
}

other_repo=$(
  for d in "$HOME"/work/*/; do
    d="${d%/}"
    [[ "$d" == *-worktrees ]] && continue
    [[ "$(cd "$d" && git rev-parse --show-toplevel 2>/dev/null)" == "$repo_root" ]] && continue
    git -C "$d" rev-parse --git-dir >/dev/null 2>&1 && basename "$d"
  done | fzf --prompt="Link repo: " --height 40% --reverse
)

if [[ -z "$other_repo" ]]; then
  tmux display-message "agent-link: no repo selected"
  exit 1
fi

other_repo_path="$HOME/work/$other_repo"
link_path="$repo_root/$other_repo"

if [[ -e "$link_path" && ! -L "$link_path" ]]; then
  tmux display-message "agent-link: $other_repo already exists in this worktree and isn't a symlink, refusing to overwrite"
  exit 1
fi

ln -sfn "$other_repo_path" "$link_path"
tmux display-message "agent-link: linked $other_repo -> $link_path"

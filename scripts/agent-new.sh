#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || true

if [[ -z "$repo_root" ]]; then
  repo_root=$(
    for d in "$HOME"/work/*/; do
      d="${d%/}"
      [[ "$d" == *-worktrees ]] && continue
      if git -C "$d" rev-parse --git-dir >/dev/null 2>&1; then
        basename "$d"
      fi
    done | fzf --prompt="Repo: " --height 40% --reverse
  )
  if [[ -z "$repo_root" ]]; then
    echo "No repo selected." >&2
    exit 1
  fi
  repo_root="$HOME/work/$repo_root"
fi

repo_name=$(basename "$repo_root")

read -rp "Branch name for new agent worktree: " branch
if [[ -z "$branch" ]]; then
  echo "Branch name cannot be empty." >&2
  exit 1
fi

worktree_dir="${repo_root}-worktrees/${branch}"
mkdir -p "$(dirname "$worktree_dir")"

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/${branch}"; then
  git -C "$repo_root" worktree add "$worktree_dir" "$branch"
else
  git -C "$repo_root" worktree add -b "$branch" "$worktree_dir"
fi

session_name="${repo_name}-${branch}"
session_name="${session_name//[:./]/_}"

# sesh (2.x) derives the tmux session name from the target directory's
# basename and has no --name flag to override it. Pre-create the tmux
# session with the desired name pointed at the worktree, then hand off
# to sesh so it manages/attaches to that existing session.
if ! tmux has-session -t "$session_name" 2>/dev/null; then
  tmux new-session -d -s "$session_name" -c "$worktree_dir"
  tmux send-keys -t "$session_name" "claude --dangerously-skip-permissions" C-m
fi
sesh connect "$session_name"

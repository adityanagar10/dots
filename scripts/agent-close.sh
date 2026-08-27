#!/usr/bin/env bash
set -euo pipefail

# Bound to prefix+X as:
#   run-shell "~/scripts/agent-close.sh '#{session_name}' '#{pane_current_path}'"
# tmux expands #{session_name}/#{pane_current_path} against the invoking
# pane before spawning this script, since a detached run-shell process has
# no tmux "current pane" of its own to query via display-message.
#
# Closes out the current agent session: switches every client attached to
# it away first (a tmux session can't kill itself out from under an
# attached client mid-script), then removes the git worktree and deletes
# the branch.

session_name="${1:?usage: agent-close.sh <session_name> <pane_path>}"
pane_path="${2:?usage: agent-close.sh <session_name> <pane_path>}"

repo_root=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null) || {
  tmux display-message "agent-close: not inside a git repository"
  exit 1
}

worktree_dir="$repo_root"
branch=$(git -C "$worktree_dir" rev-parse --abbrev-ref HEAD)

if [[ "$branch" == "HEAD" ]]; then
  tmux display-message "agent-close: worktree is in detached HEAD state, refusing to delete a branch"
  exit 1
fi

common_dir=$(git -C "$worktree_dir" rev-parse --path-format=absolute --git-common-dir)
git_dir=$(git -C "$worktree_dir" rev-parse --path-format=absolute --git-dir)
if [[ "$common_dir" == "$git_dir" ]]; then
  tmux display-message "agent-close: this is the main worktree, refusing to remove it"
  exit 1
fi

main_repo_root=$(dirname "$common_dir")

# Move every client currently attached to this session elsewhere before
# killing it, targeting each client explicitly by name (-c) rather than
# relying on an ambiguous "current client" — this script has no client
# context of its own since it runs detached via run-shell.
other_session=$(tmux list-sessions -F '#{session_name}' | grep -v "^${session_name}$" | head -n1 || true)
attached_clients=$(tmux list-clients -t "$session_name" -F '#{client_name}' 2>/dev/null || true)
if [[ -n "$attached_clients" ]]; then
  while IFS= read -r client; do
    [[ -z "$client" ]] && continue
    if [[ -n "$other_session" ]]; then
      tmux switch-client -c "$client" -t "$other_session"
    else
      tmux detach-client -t "$client"
    fi
  done <<< "$attached_clients"
fi

tmux kill-session -t "$session_name"
git -C "$main_repo_root" worktree remove "$worktree_dir" --force
git -C "$main_repo_root" branch -D "$branch"

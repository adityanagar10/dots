# tmux cheat-sheet

## Panes
- `prefix h/j/k/l` — move between panes (vi-style)
- `prefix |` — split horizontally
- `prefix -` — split vertically
- `prefix =` — equalize all splits (tiled layout)
- `v` (in copy-mode) — begin selection
- `y` (in copy-mode) — copy selection and exit

## Sessions
- `prefix C-n` — new session (prompts for name)
- `prefix R` — rename current session
- `prefix C-j` — switch session via fzf popup
- `prefix o` — sessionx picker
- `prefix d` — detach

## Agent workflow (this setup)
- `prefix A` — new agent: prompts for branch name, creates a git worktree,
  opens a tmux session there, launches `claude`
- `prefix X` — close current agent: switches away, kills this session,
  removes its worktree, deletes its branch (refuses on the main worktree)
- `prefix L` — link another repo into this worktree: fzf-pick a repo from
  `~/work/*`, symlinks it in for read access (e.g. browse loyalty's code
  while working in pos)
- `sesh` (from shell, outside tmux) — fuzzy picker across tmux sessions,
  git worktrees, and zoxide paths

## Floating / utility
- `prefix p` — floax floating pane
- `prefix G` — lazygit popup (scoped to current pane's repo)
- `prefix K` — k9s popup (cluster status)
- `prefix ?` — this cheat-sheet

## Misc
- `prefix r` — reload tmux config

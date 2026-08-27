# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# oh-my-zsh removed: prompt now comes from starship, and
# zsh-autosuggestions / zsh-syntax-highlighting are sourced directly from
# their brew installs below instead of via the oh-my-zsh plugin loader.
# git completions are provided by zsh's own bundled git completion (compinit).

autoload -Uz compinit && compinit

# Uncomment the following line to enable command auto-correction.
# setopt CORRECT

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt EXTENDED_HISTORY

# User configuration

# ====================== Environment & PATH (merged) ======================
typeset -U path PATH

export TMUX_CONF="$HOME/.config/tmux/tmux.conf" # tmux
export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer/" # tldr
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml" # starship
export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
export EDITOR=nvim
export VISUAL=nvim

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# ====================== Completions (merged) ======================
# ~/zsh/completions doesn't exist on this machine yet; guarded so it's a no-op until created.
[ -d "$HOME/zsh/completions" ] && fpath=("$HOME/zsh/completions" $fpath)

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="/opt/homebrew/opt/node@20/bin:$PATH"

# Go binaries
export PATH="$HOME/go/bin:$PATH"

command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init - --no-rehash zsh)"

export GITHUB_USERNAME="adityanagar10"
[ -f "$HOME/.config/secrets.zsh" ] && source "$HOME/.config/secrets.zsh"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Wait for Tilt services to be ready
waitfor() {
    local tilt_url="${1:-http://localhost:10350}"
    local check_interval=2

    echo "Waiting for all Tilt services to be ready..."
    echo "Tilt UI: $tilt_url"
    echo "Checking every ${check_interval}s..."
    echo ""

    local start_time=$(date +%s)

    while true; do
        # Query Tilt API for resource status to temp file
        local tmpfile=$(mktemp)
        curl -s "${tilt_url}/api/view" > "$tmpfile"

        if [[ ! -s "$tmpfile" ]]; then
            local end_time=$(date +%s)
            local elapsed=$((end_time - start_time))
            printf "⏳ Waiting for Tilt... (${elapsed}s) [API not responding]\r"
            rm -f "$tmpfile"
            sleep "$check_interval"
            continue
        fi

        # Check if all resources are ready using jq
        local total=$(jq '.uiResources | length' "$tmpfile")
        local ready=$(jq '[.uiResources[] | select((.status.runtimeStatus == "ok" or .status.runtimeStatus == "not_applicable") and .status.updateStatus == "ok")] | length' "$tmpfile")
        local building=$(jq '[.uiResources[] | select(.status.updateStatus == "pending")] | length' "$tmpfile")
        local errors=$(jq '[.uiResources[] | select(.status.updateStatus == "error" or .status.runtimeStatus == "error")] | length' "$tmpfile")

        rm -f "$tmpfile"

        if [[ "$total" -eq "$ready" ]] && [[ "$building" -eq 0 ]] && [[ "$errors" -eq 0 ]]; then
            local end_time=$(date +%s)
            local elapsed=$((end_time - start_time))

            echo ""
            echo "✅ All services are UP! (took ${elapsed}s)"
            echo "Tilt UI: $tilt_url"
            echo "Ready: $ready/$total services"

            # System notification (macOS)
            osascript -e "display notification \"All $total services are ready!\" with title \"Tilt Ready\" sound name \"Glass\"" 2>/dev/null

            # Terminal bell
            echo -e "\a"

            break
        else
            local end_time=$(date +%s)
            local elapsed=$((end_time - start_time))
            printf "⏳ Building/Starting... (${elapsed}s) [Ready: ${ready:-0}/${total:-?} | Building: ${building:-0} | Errors: ${errors:-0}]\r"
            sleep "$check_interval"
        fi
    done
}

. "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# ====================== zsh-vi-mode / zvm (merged, guarded) ======================
# If Using ZVM: some shell keybinds may need to be added to zsh_after_init_commands()
[ -f "$HOME/zsh/zvm-config.zsh" ] && source "$HOME/zsh/zvm-config.zsh"
# must have zsh-vi-mode installed with brew: brew install jeffreytse/zsh-vi-mode/zsh-vi-mode
[ -f "/opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" ] && \
    source "/opt/homebrew/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

#============ Default zsh vi mode ===========
# set -o vi

# ctrl y accept requires zsh-autosuggestions to be active
# bindkey -M viins '^Y' autosuggest-accept

# bindkey -M viins '^P' up-line-or-beginning-search
# bindkey -M viins '^N' down-line-or-beginning-search

# ====================== FZF conf (merged, guarded) ======================
# Set up FZF key bindings and fuzzy completion
# Keymaps for this is available at https://github.com/junegunn/fzf-git.sh
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git "
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
fi

export FZF_DEFAULT_OPTS="--height 50% --layout=default --border --color=hl:#2dd4bf"

# Setup fzf previews (requires bat/eza; falls back gracefully if missing since
# these are just fzf preview commands, not eval'd at shell startup)
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons=always --tree --color=always {} | head -200'"

# fzf preview for tmux
export FZF_TMUX_OPTS=" -p90%,70% "

# ================ Initializers and Sources (merged, guarded) ==============
command -v gdircolors >/dev/null 2>&1 && eval "$(gdircolors)"

# wtp (gitworktree plus)
command -v wtp >/dev/null 2>&1 && eval "$(wtp shell-init zsh)"

# gitbutler
command -v but >/dev/null 2>&1 && eval "$(but completions zsh)"

# starship
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# zoxide
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# fzf
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
[ -f "$HOME/scripts/fzf-git.sh" ] && source "$HOME/scripts/fzf-git.sh" # fzf git

# Atuin configs
if command -v atuin >/dev/null 2>&1; then
    export ATUIN_NOBIND="true"
    eval "$(atuin init zsh)"
    bindkey '^r' atuin-search-viins
fi

# fnm
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"

# ============= Sesh Tmux conf (merged, guarded) ==============
if command -v sesh >/dev/null 2>&1; then
    function sesh-sessions() {
        {
            exec </dev/tty
            exec <&1
            local session
            session=$(
                sesh list -t -c | fzf --height 50% --border-label ' sesh ' --border --prompt '🛸  '
            )
            zle reset-prompt > /dev/null 2>&1 || true
            [[ -z "$session" ]] && return
            sesh connect $session
        }
    }

    zle     -N             sesh-sessions
    bindkey -M emacs '\es' sesh-sessions
    bindkey -M vicmd '\es' sesh-sessions
    bindkey -M viins '\es' sesh-sessions
fi

# ================= ALIAS (merged) ===================
# For Running Go Server using Air
alias air='$(go env GOPATH)/bin/air'

# other Aliases shortcuts
alias c="clear"
alias e="exit"
alias vim="nvim"

# Tmux
alias tmux="tmux -f $TMUX_CONF"
alias a="attach"
# calls the tmux new session script
[ -f "$HOME/scripts/tmux-sessionizer.sh" ] && alias tns="$HOME/scripts/tmux-sessionizer.sh"

# fzf
# called from ~/scripts/
[ -f "$HOME/scripts/fzf_listoldfiles.sh" ] && alias nlof="$HOME/scripts/fzf_listoldfiles.sh"
# opens documentation through fzf (eg: git,zsh etc.)
alias fman="compgen -c | fzf | xargs man"

# zoxide (called from ~/scripts/)
[ -f "$HOME/scripts/zoxide_openfiles_nvim.sh" ] && alias nzo="$HOME/scripts/zoxide_openfiles_nvim.sh"

# Next level ls (requires eza; falls back to plain ls if not installed)
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --no-filesize --long --color=always --icons=always --no-user"
fi

# tree
alias tree="tree -L 3 -a -I '.git' --charset X "
alias dtree="tree -L 3 -a -d -I '.git' --charset X "

# lstr
command -v lstr >/dev/null 2>&1 && alias lstr="lstr --icons"

# git aliases
alias gt="git"
alias ga="git add ."
alias gs="git status -s"
alias gc='git commit -m'
alias glog='git log --oneline --graph --all'
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'

alias nvim-scratch="NVIM_APPNAME=nvim-scratch nvim"
alias nvimn="NVIM_APPNAME=nvim-nightly $HOME/.local/nvim-nightly/bin/nvim"
alias nvimmin="NVIM_APPNAME=nvim-min nvim"
alias nvimpack="NVIM_APPNAME=nvim-pack nvim"

# lazygit
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"

# mpd start alias
alias mpds="mpd ~/.config/mpd/mpd.conf"

# obsidian icloud path
alias sethvault="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/sethVault/"

# rsync
alias rsynct="rsync -avh --progress --partial"

# brew installations (new mac systems brew path: opt/homebrew , not usr/local )
# zsh-syntax-highlighting must be sourced LAST, after all other plugins/widgets.
[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

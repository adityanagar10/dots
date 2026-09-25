#!/usr/bin/env bash
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  ok: $dest already linked"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.bak-$(date +%Y%m%d%H%M%S)"
    echo "  backing up existing $dest -> $backup"
    mv "$dest" "$backup"
  fi
  ln -s "$src" "$dest"
  echo "  linked: $dest -> $src"
}

echo "==> Installing Homebrew packages"
brew install sesh lazygit k9s starship fzf direnv zoxide fd \
  font-jetbrains-mono-nerd-font font-iosevka-nerd-font font-hack-nerd-font

echo "==> Installing tmux plugin manager (tpm)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  echo "  ok: tpm already cloned"
fi

echo "==> Linking configs"
link "$DOTS_DIR/zshrc" "$HOME/.zshrc"
link "$DOTS_DIR/tmux" "$HOME/.config/tmux"
link "$DOTS_DIR/nvim" "$HOME/.config/nvim"
link "$DOTS_DIR/starship" "$HOME/.config/starship"
link "$DOTS_DIR/kitty" "$HOME/.config/kitty"
link "$DOTS_DIR/cheatsheets" "$HOME/.config/cheatsheets"

echo "==> Linking scripts"
mkdir -p "$HOME/scripts"
for f in "$DOTS_DIR"/scripts/*.sh; do
  link "$f" "$HOME/scripts/$(basename "$f")"
done

echo "==> Linking competitive-programming templates"
link "$DOTS_DIR/cp/templates" "$HOME/cp/templates"

echo ""
echo "==> Done. Remaining manual steps:"
echo "  1. cp $DOTS_DIR/secrets.zsh.example ~/.config/secrets.zsh"
echo "     then edit it with real Grafana tokens, and: chmod 600 ~/.config/secrets.zsh"
echo "  2. gh auth login   (GitHub CLI auth)"
echo "  3. Register Grafana MCP servers:"
echo "     claude mcp add -s user grafana-ops --env GRAFANA_URL=<ops-url> --env GRAFANA_SERVICE_ACCOUNT_TOKEN=\$GRAFANA_OPS_TOKEN -- uvx mcp-grafana"
echo "     claude mcp add -s user grafana-prod --env GRAFANA_URL=<prod-url> --env GRAFANA_SERVICE_ACCOUNT_TOKEN=\$GRAFANA_PROD_TOKEN -- uvx mcp-grafana"
echo "  4. Open tmux and press prefix+I to install tmux plugins (tpm)"
echo "  5. Karabiner-Elements: install the app, then merge $DOTS_DIR/karabiner/karabiner.json"
echo "     into ~/.config/karabiner/karabiner.json by hand (not auto-linked — it may"
echo "     contain other machine-specific rules/profiles). The gaming-keyboard Alt/Cmd"
echo "     swap rule is scoped to a specific vendor_id/product_id; update or drop it"
echo "     if this machine's device differs. Validate with:"
echo "     karabiner_cli --lint-complex-modifications ~/.config/karabiner/karabiner.json"
echo "  6. Comic Code font is not bundled here (unclear redistribution license)."
echo "     Install it yourself, then set font_family in kitty.conf / font_face in"
echo "     Sublime's Preferences.sublime-settings / editor.fontFamily in VS Code's"
echo "     settings.json to \"Comic Code\" (or use prefix+font-picker in kitty)."

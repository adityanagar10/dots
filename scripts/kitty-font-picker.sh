#!/usr/bin/env bash
# Font picker for kitty. Lists a curated set of installed fonts via fzf,
# rewrites the font_family line in kitty.conf, and reloads kitty live via
# remote control (kitty has no set-font-family remote command, only
# set-font-size, so editing the config + `kitty @ load-config` is the
# actual mechanism for a live family change).
set -euo pipefail

KITTY_CONF="$HOME/.config/kitty/kitty.conf"

fonts=(
  "FiraCode Nerd Font Mono"
  "JetBrainsMono Nerd Font Mono"
  "Iosevka Nerd Font Mono"
  "Hack Nerd Font Mono"
  "Comic Code"
  "Comic Code Ligatures"
)

chosen=$(printf '%s\n' "${fonts[@]}" | fzf --prompt="Font: " --height 40% --reverse)
[ -n "$chosen" ] || exit 0

# Comment out any existing font_family line (active or already-commented),
# so re-running this always leaves exactly one active font_family line.
sed -i '' -E 's/^#? ?(font_family .*)$/# \1/' "$KITTY_CONF"

if grep -qF "# font_family $chosen" "$KITTY_CONF"; then
  sed -i '' "s/^# font_family $chosen\$/font_family $chosen/" "$KITTY_CONF"
else
  # Not a pre-existing line: insert a new active one right before font_size.
  sed -i '' "/^font_size /i\\
font_family $chosen
" "$KITTY_CONF"
fi

kitty @ load-config 2>/dev/null || true
echo "Switched to: $chosen"

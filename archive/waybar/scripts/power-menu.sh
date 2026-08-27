#!/bin/bash
# ~/.config/waybar/scripts/power-menu.sh

# Power menu options
options="🔒 Lock\n🌙 Sleep\n🔄 Restart\n⏻ Shutdown\n🚪 Logout"

# Show menu with wofi
chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --width 200 --height 220)

case $chosen in
    "🔒 Lock")
        hyprlock
        ;;
    "🌙 Sleep")
        systemctl suspend
        ;;
    "🔄 Restart")
        systemctl reboot
        ;;
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "🚪 Logout")
        hyprctl dispatch exit
        ;;
esac

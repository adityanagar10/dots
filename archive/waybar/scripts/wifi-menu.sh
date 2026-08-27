#!/bin/bash
# ~/.config/waybar/scripts/wifi-menu.sh

# Check if nmcli is installed
if ! command -v nmcli &> /dev/null; then
    notify-send "NetworkManager not found" "Please install networkmanager"
    exit 1
fi

# Get current connection status
current_wifi=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
wifi_status=$(nmcli radio wifi)

# Build menu options
if [ "$wifi_status" = "enabled" ]; then
    options="📶 WiFi: ON\n📡 Disconnect\n🔄 Refresh\n❌ Turn Off WiFi\n⚙️ Settings"
    if [ -n "$current_wifi" ]; then
        options="📶 Connected: $current_wifi\n$options"
    fi
    
    # Add available networks
    options="$options\n---Available Networks---"
    available_networks=$(nmcli -t -f ssid,signal,security dev wifi list | head -10 | while read line; do
        ssid=$(echo "$line" | cut -d: -f1)
        signal=$(echo "$line" | cut -d: -f2)
        security=$(echo "$line" | cut -d: -f3)
        if [ -n "$ssid" ] && [ "$ssid" != "$current_wifi" ]; then
            if [ -n "$security" ]; then
                echo "🔒 $ssid ($signal%)"
            else
                echo "📶 $ssid ($signal%)"
            fi
        fi
    done)
    options="$options\n$available_networks"
else
    options="📶 WiFi: OFF\n✅ Turn On WiFi\n⚙️ Settings"
fi

# Show menu
chosen=$(echo -e "$options" | wofi --dmenu --prompt "WiFi Menu" --width 300 --height 400)

case $chosen in
    "📶 WiFi: ON"|"📶 WiFi: OFF")
        # Just status, do nothing
        ;;
    "✅ Turn On WiFi")
        nmcli radio wifi on
        notify-send "WiFi" "WiFi turned on"
        ;;
    "❌ Turn Off WiFi")
        nmcli radio wifi off
        notify-send "WiFi" "WiFi turned off"
        ;;
    "📡 Disconnect")
        nmcli device disconnect wlan0 2>/dev/null || nmcli device disconnect wlp* 2>/dev/null
        notify-send "WiFi" "Disconnected from WiFi"
        ;;
    "🔄 Refresh")
        nmcli device wifi rescan
        notify-send "WiFi" "Scanning for networks..."
        ;;
    "⚙️ Settings")
        nm-connection-editor &
        ;;
    "Connected: "*|"---Available Networks---")
        # Skip these options
        ;;
    *)
        # Connect to selected network
        if [[ $chosen == 🔒* ]] || [[ $chosen == 📶* ]]; then
            # Extract SSID from the chosen option
            ssid=$(echo "$chosen" | sed 's/^[🔒📶] //' | sed 's/ ([0-9]*%)$//')
            
            # Check if network requires password
            if [[ $chosen == 🔒* ]]; then
                password=$(echo "" | wofi --dmenu --prompt "Password for $ssid" --password)
                if [ -n "$password" ]; then
                    nmcli device wifi connect "$ssid" password "$password"
                    if [ $? -eq 0 ]; then
                        notify-send "WiFi" "Connected to $ssid"
                    else
                        notify-send "WiFi Error" "Failed to connect to $ssid"
                    fi
                fi
            else
                nmcli device wifi connect "$ssid"
                if [ $? -eq 0 ]; then
                    notify-send "WiFi" "Connected to $ssid"
                else
                    notify-send "WiFi Error" "Failed to connect to $ssid"
                fi
            fi
        fi
        ;;
esac

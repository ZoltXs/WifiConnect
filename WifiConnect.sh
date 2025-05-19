#!/bin/bash

# WifiConnect - ColorBerry-Kali-Wi-Fi Manager
# By N@Xs

show_error() {
  whiptail --title "❌ Error" --msgbox "$1" 12 40
}

show_success() {
  whiptail --title "✅ Success" --msgbox "$1" 12 40
}

scan_networks() {
  {
    for i in {1..10}; do echo $((i * 10)); sleep 0.1; done
  } | whiptail --gauge "Scanning for Wi-Fi networks..." 12 40 0

  NETWORKS=$(nmcli -f SSID,SIGNAL dev wifi list | tail -n +2 | sed 's/  */ /g')
  OPTIONS=()

  while IFS= read -r line; do
    SSID=$(echo "$line" | awk '{print $1}')
    SIGNAL=$(echo "$line" | awk '{print $2}')
    [[ -n "$SSID" && ! " ${OPTIONS[*]} " =~ " $SSID " ]] && OPTIONS+=("$SSID" "$SIGNAL%")
  done <<< "$NETWORKS"

  if [ ${#OPTIONS[@]} -eq 0 ]; then
    show_error "No Wi-Fi networks found."
    return 1
  fi

  SELECTED_SSID=$(whiptail --title "Wi-Fi Networks" --menu "Select a network:" 12 40 4 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return 1

  connect_to_network "$SELECTED_SSID"
}

create_nmconnection() {
  local SSID="$1"
  local PASSWORD="$2"
  local UUID_GEN=$(cat /proc/sys/kernel/random/uuid)
  local FILE="/etc/NetworkManager/system-connections/${SSID}.nmconnection"

  sudo bash -c "cat > \"$FILE\" <<EOF
[connection]
id=$SSID
uuid=$UUID_GEN
type=wifi
autoconnect=true
permissions=

[wifi]
ssid=$SSID
mode=infrastructure

[wifi-security]
key-mgmt=wpa-psk
psk=$PASSWORD

[ipv4]
method=auto

[ipv6]
method=auto
EOF"

  sudo chmod 600 "$FILE"
  sudo chown root:root "$FILE"
  sudo nmcli connection reload
}

connect_to_network() {
  local SSID="$1"
  local PASSWORD=$(whiptail --title "Wi-Fi Password" --inputbox "Enter the password for '$SSID':" 12 40 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return 1

  {
    for i in {1..10}; do echo $((i * 10)); sleep 0.2; done
  } | whiptail --gauge "Connecting to '$SSID'..." 12 40 0

  if nmcli device wifi connect "$SSID" password "$PASSWORD"; then
    create_nmconnection "$SSID" "$PASSWORD"
    show_success "Successfully connected and saved to '$SSID'"
  else
    show_error "Could not connect. Please check the password."
  fi
}

manage_saved_networks() {
  FILES=$(ls /etc/NetworkManager/system-connections/*.nmconnection 2>/dev/null)
  if [ -z "$FILES" ]; then
    show_error "No saved networks found."
    return
  fi

  OPTIONS=()
  for file in $FILES; do
    SSID=$(basename "$file" .nmconnection)
    OPTIONS+=("$SSID" "Delete")
  done

  SELECTED=$(whiptail --title "Saved Networks" --menu "Select a network to delete:" 12 40 4 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return

  sudo rm "/etc/NetworkManager/system-connections/${SELECTED}.nmconnection"
  sudo nmcli connection delete "$SELECTED" &>/dev/null
  show_success "Network '$SELECTED' deleted successfully."
}

main() {
  whiptail --title "WifiConnect" --msgbox "       Welcome to WifiConnect\n\n            By N@Xs" 12 40

  while true; do
    OPTION=$(whiptail --title "WifiConnect" --menu "Choose an option:" 12 40 3 \
      "1" "Scan and connect to Wi-Fi networks" \
      "2" "Manage saved networks" \
      "3" "Exit" 3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && break

    case $OPTION in
      1) scan_networks ;;
      2) manage_saved_networks ;;
      3)
        clear
        echo "Thanks for using WifiConnect"
        sleep 1
        clear
        exit 0
        ;;
    esac
  done
}

main

#!/bin/bash

# WifiConnect - ColorBerry-Kali-Wi-Fi Manager
# Por N@Xs

mostrar_error() {
  whiptail --title "❌ Error" --msgbox "$1" 12 40
}

mostrar_exito() {
  whiptail --title "✅ Éxito" --msgbox "$1" 12 40
}

buscar_redes() {
  {
    for i in {1..10}; do echo $((i * 10)); sleep 0.1; done
  } | whiptail --gauge "Buscando redes Wi-Fi..." 12 40 0

  REDES=$(nmcli -f SSID,SIGNAL dev wifi list | tail -n +2 | sed 's/  */ /g')
  OPCIONES=()

  while IFS= read -r linea; do
    SSID=$(echo "$linea" | awk '{print $1}')
    SIGNAL=$(echo "$linea" | awk '{print $2}')
    [[ -n "$SSID" && ! " ${OPCIONES[*]} " =~ " $SSID " ]] && OPCIONES+=("$SSID" "$SIGNAL%")
  done <<< "$REDES"

  if [ ${#OPCIONES[@]} -eq 0 ]; then
    mostrar_error "No se encontraron redes Wi-Fi."
    return 1
  fi

  SSID_SELECCIONADO=$(whiptail --title "Redes Wi-Fi" --menu "Seleccione una red:" 12 40 4 "${OPCIONES[@]}" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return 1

  conectar_red "$SSID_SELECCIONADO"
}

crear_nmconnection() {
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

conectar_red() {
  local SSID="$1"
  local PASSWORD=$(whiptail --title "Contraseña Wi-Fi" --inputbox "Ingrese la contraseña para '$SSID':" 12 40 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return 1

  {
    for i in {1..10}; do echo $((i * 10)); sleep 0.2; done
  } | whiptail --gauge "Conectando a '$SSID'..." 12 40 0

  if nmcli device wifi connect "$SSID" password "$PASSWORD"; then
    crear_nmconnection "$SSID" "$PASSWORD"
    mostrar_exito "Conectado y guardado correctamente a '$SSID'"
  else
    mostrar_error "No se pudo conectar. Verifique la contraseña."
  fi
}

gestionar_redes_guardadas() {
  FILES=$(ls /etc/NetworkManager/system-connections/*.nmconnection 2>/dev/null)
  if [ -z "$FILES" ]; then
    mostrar_error "No hay redes guardadas."
    return
  fi

  OPCIONES=()
  for file in $FILES; do
    SSID=$(basename "$file" .nmconnection)
    OPCIONES+=("$SSID" "Eliminar")
  done

  SELECCIONADA=$(whiptail --title "Redes Guardadas" --menu "Seleccione una red para eliminar:" 12 40 4 "${OPCIONES[@]}" 3>&1 1>&2 2>&3)
  [ $? -ne 0 ] && return

  sudo rm "/etc/NetworkManager/system-connections/${SELECCIONADA}.nmconnection"
  sudo nmcli connection delete "$SELECCIONADA" &>/dev/null
  mostrar_exito "Red '$SELECCIONADA' eliminada correctamente."
}

main() {
  whiptail --title "WifiConnect" --msgbox "       Bienvenido a WifiConnect\n\n            By N@Xs" 12 40

  while true; do
    OPCION=$(whiptail --title "WifiConnect" --menu "Seleccione una opción:" 12 40 3 \
      "1" "Buscar y conectar a redes Wi-Fi" \
      "2" "Gestionar redes guardadas" \
      "3" "Salir" 3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && break

    case $OPCION in
      1) buscar_redes ;;
      2) gestionar_redes_guardadas ;;
      3)
        clear
        echo "Gracias por usar WifiConnect"
        sleep 1
        clear
        exit 0
        ;;
    esac
  done
}

main

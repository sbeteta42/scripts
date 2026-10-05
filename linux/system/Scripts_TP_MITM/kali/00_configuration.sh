#!/usr/bin/env bash
# Avant la séance : saisir les valeurs réellement relevées sur les consoles.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
user_only; need ip python3; assert_idle
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Restaurer l’essai actif avant de changer les paramètres.'
mkdir -p "$LAB_DIR"; [[ ! -e "$LAB_DIR/kali.env" ]] || die 'kali.env existe ; l’archiver manuellement après contrôle avant de reconfigurer.'
ip -br addr; ip route
read -r -p 'Interface LAN réelle Kali : ' IFACE
read -r -p 'IPv4 réelle Kali : ' KALI
read -r -p 'IPv4 réelle client : ' CLIENT
read -r -p 'IPv4 LAN réelle FreeSCO : ' GW
read -r -p 'IPv4 réelle serveur pédagogique : ' WEB
read -r -p 'MAC LAN FreeSCO (console, xx:xx:xx:xx:xx:xx) : ' GW_MAC
read -r -p 'MAC client (console) : ' CLIENT_MAC
private_ip "$KALI" "$CLIENT" "$GW" "$WEB"; valid_mac "$GW_MAC"; valid_mac "$CLIENT_MAC"
check_interface "$IFACE" "$KALI" "$GW" "$CLIENT"
KALI_MAC=$(cat "/sys/class/net/$IFACE/address")
printf 'IFACE=%q\nKALI=%q\nCLIENT=%q\nGW=%q\nWEB=%q\nGW_MAC=%q\nCLIENT_MAC=%q\nKALI_MAC=%q\n' \
 "$IFACE" "$KALI" "$CLIENT" "$GW" "$WEB" "$GW_MAC" "$CLIENT_MAC" "$KALI_MAC" > "$LAB_DIR/kali.env"
printf 'Paramètres sauvegardés dans %s/kali.env.\n' "$LAB_DIR"

#!/usr/bin/env bash
# Avant 13 h : inventaire réel du client Debian, indépendant de l’interface Kali.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
user_only; need python3 ip; mkdir -p "$LAB_DIR"
[[ ! -e "$LAB_DIR/client.env" ]] || die 'client.env existe : conserver la référence avant une reconfiguration.'
ip -br addr; ip route
read -r -p 'Interface LAN réelle client : ' CLIENT_IFACE
read -r -p 'IPv4 réelle client : ' CLIENT
read -r -p 'IPv4 LAN réelle FreeSCO : ' GW
read -r -p 'IPv4 réelle serveur pédagogique : ' WEB
read -r -p 'MAC LAN FreeSCO vérifiée sur console : ' GW_MAC
private_ip "$CLIENT" "$GW" "$WEB"; valid_mac "$GW_MAC"
check_interface "$CLIENT_IFACE" "$CLIENT" "$GW"
printf 'CLIENT_IFACE=%q\nCLIENT=%q\nGW=%q\nWEB=%q\nGW_MAC=%q\n' \
 "$CLIENT_IFACE" "$CLIENT" "$GW" "$WEB" "$GW_MAC" > "$LAB_DIR/client.env"

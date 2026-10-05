#!/usr/bin/env bash
# Usage : bash 10_mac_temporaire.sh changer | restaurer
# Console locale uniquement. Aucun renouvellement DHCP automatique.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
user_only; need macchanger ip
# Pour récupérer après un changement DHCP, la restauration n’exige pas l’IP initiale.
[[ -r "$LAB_DIR/kali.env" ]] || die 'Configurer Kali.'
source "$LAB_DIR/kali.env"
[[ "$IFACE" =~ ^[a-zA-Z0-9_-]+$ && -d "/sys/class/net/$IFACE" ]] || die 'Interface incorrecte.'
save="$LAB_DIR/mac_avant.txt"
restore_mac() {
 [[ -r "$save" ]] || die 'MAC initiale absente.'
 local old; old=$(cat "$save"); valid_mac "$old"
 sudo ip link set dev "$IFACE" down
 sudo macchanger -m "$old" "$IFACE"
 sudo ip link set dev "$IFACE" up
 [[ "$(cat "/sys/class/net/$IFACE/address")" == "${old,,}" ]] || die 'MAC non restaurée : vérifier NetworkManager/pilote.'
 macchanger -s "$IFACE"; ip -br addr show "$IFACE"; ip route
 printf 'MAC restaurée ; recontrôler l’IP et la route avant le TP2.\n'
}
assert_idle
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Essai actif : restaurer celui-ci avant le TP1.'
case "${1:-}" in
 restaurer) restore_mac;;
 changer)
  [[ -z "${SSH_CONNECTION:-}" ]] || die 'Utiliser la console VMware, pas SSH.'
  load_role kali
  [[ ! -e "$save" ]] || die 'Une référence MAC existe ; la conserver, ne pas l’écraser.'
  cat "/sys/class/net/$IFACE/address" > "$save"
  ip -br addr > "$LAB_DIR/preuves/TP1_IP_avant.txt"
  # Même lors d’une interruption, tenter la remise en état ; sauvegarde conservée.
  trap restore_mac EXIT
  sudo -v; sudo ip link set dev "$IFACE" down
  sudo macchanger -r "$IFACE"; sudo ip link set dev "$IFACE" up
  { macchanger -s "$IFACE"; ip -br addr; ip route; } | tee "$LAB_DIR/preuves/TP1_MAC_temporaire.txt"
  read -r -p 'Relever MAC/IP/DHCP et la capture ; Entrée pour restaurer : ' _
  ;;
 *) die 'Usage : changer | restaurer';;
esac

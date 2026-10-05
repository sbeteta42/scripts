#!/usr/bin/env bash
# Usage : bash 20_preparer_essai.sh TP2|TP3|TP4|TP5[-suffixe]
# Sauvegarde distincte AVANT toute modification. Ne touche pas aux politiques filter.
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; need sysctl iptables iptables-save awk; assert_idle; sudo -v
id="${1:-}"; [[ "$id" =~ ^TP[2345](-[A-Za-z0-9_-]+)?$ ]] || die 'Identifiant TP invalide.'
TP="${id%%-*}"; REF="$LAB_DIR/preuves/$id"
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Un essai reste actif ; utiliser 90_restaurer_essai.sh.'
[[ "$(cat "/sys/class/net/$IFACE/address")" == "$KALI_MAC" ]] || die 'MAC Kali différente de l’inventaire initial.'
if sudo iptables -t nat -S LAB_MITM >/dev/null 2>&1; then die 'LAB_MITM existe déjà : vérifier les essais précédents.'; fi
[[ "$TP" != TP3 && "$TP" != TP4 ]] || assert_server_cert
# Les processus précédents doivent être arrêtés ; l’apprenant vérifie aussi les caches.
ip neigh show dev "$IFACE"
mkdir "$REF" || die 'Référence existante : utiliser un nouveau suffixe après restauration.'
cp "$LAB_DIR/kali.env" "$REF/kali.env"
sysctl_snapshot > "$REF/sysctl_avant.conf"; validate_sysctl "$REF/sysctl_avant.conf"
sudo sysctl -a -e > "$REF/sysctl_complet_avant.txt" 2> "$REF/sysctl_avertissements.txt"
sudo iptables-save > "$REF/iptables_avant.txt"
[[ -s "$REF/iptables_avant.txt" ]] || die 'Sauvegarde pare-feu vide.'
if command -v nft >/dev/null; then sudo nft list ruleset > "$REF/nft_avant.txt"; fi
ip -br addr > "$REF/adresses_avant.txt"; ip route > "$REF/routes_avant.txt"
sha256sum "$REF/kali.env" "$REF/sysctl_avant.conf" "$REF/iptables_avant.txt" > "$REF/references.sha256"
# Écrire le témoin avant mutation : si une commande échoue, la restauration reste possible.
printf '%s\n' "$id" > "$LAB_DIR/essai_actif"
trap 'printf "Essai préparé ou partiel : restaurer avec 90_restaurer_essai.sh %s\n" "$id" >&2' ERR
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w "net.ipv4.conf.$IFACE.send_redirects=0"
if [[ "$TP" == TP3 || "$TP" == TP4 ]]; then
 port=80; [[ "$TP" != TP4 ]] || port=443
 # Témoins avant chacune des créations, utiles en cas d’échec partiel.
 touch "$REF/nat_chaine_possedee"
 sudo iptables -t nat -N LAB_MITM
 sudo iptables -t nat -A LAB_MITM -p tcp --dport "$port" -j REDIRECT --to-ports 8080
 touch "$REF/nat_saut_possede"
 sudo iptables -t nat -I PREROUTING 1 -i "$IFACE" -s "$CLIENT" -d "$WEB" -j LAB_MITM
 sudo iptables -t nat -L LAB_MITM -n -v
fi
sudo iptables -S FORWARD; sudo iptables -S INPUT; sudo iptables -S OUTPUT
printf 'Référence : %s\n' "$REF"
printf 'Vérifier les autorisations filter/nft ; aucun ACCEPT global n’a été ajouté.\n'

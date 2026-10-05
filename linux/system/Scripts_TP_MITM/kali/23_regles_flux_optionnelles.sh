#!/usr/bin/env bash
# Formateur uniquement, si les politiques filter existantes bloquent le test.
# Usage : bash 23_regles_flux_optionnelles.sh TP2[-suffixe] ajouter|retirer
# Autorisations ciblées, taguées par essai ; pas de modification des politiques.
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
user_only; need iptables; source "$LAB_DIR/kali.env"
session "${1:-}"; action="${2:-}"; assert_idle; sudo -v
[[ "$action" == ajouter || "$action" == retirer ]] || die 'Action : ajouter | retirer'
flag="$REF/filter_exceptions_possedees"
if [[ "$action" == ajouter ]]; then
 [[ ! -e "$flag" ]] || die 'Exceptions déjà créées ou essai partiel : retirer puis recontrôler.'
 touch "$flag"
else
 [[ -f "$flag" ]] || exit 0
fi
rule() {
 local chain="$1"; shift
 # Le tag utilise l’identifiant complet, jamais un nom de paquet variable.
 local args=("$@" -m comment --comment "LAB_MITM:$id" -j ACCEPT)
 if [[ "$action" == ajouter ]]; then
  sudo iptables -I "$chain" 1 "${args[@]}"
 elif sudo iptables -C "$chain" "${args[@]}" 2>/dev/null; then
  sudo iptables -D "$chain" "${args[@]}"
 fi
}
id="$1"
# Relais IPv4, même carte pour l’entrée et la sortie ; ports web pédagogiques seulement.
rule FORWARD -i "$IFACE" -o "$IFACE" -s "$CLIENT" -d "$WEB" -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED
rule FORWARD -i "$IFACE" -o "$IFACE" -s "$WEB" -d "$CLIENT" -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED
if [[ "$TP" == TP3 || "$TP" == TP4 ]]; then
 rule INPUT -i "$IFACE" -s "$CLIENT" -d "$KALI" -p tcp --dport 8080 -m conntrack --ctstate NEW,ESTABLISHED
 rule OUTPUT -o "$IFACE" -s "$KALI" -d "$CLIENT" -p tcp --sport 8080 -m conntrack --ctstate ESTABLISHED
 rule OUTPUT -o "$IFACE" -s "$KALI" -d "$WEB" -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED
 rule INPUT -i "$IFACE" -s "$WEB" -d "$KALI" -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED
fi
[[ "$action" != retirer ]] || rm "$flag"
sudo iptables -S
printf 'Vérifier également nftables/UFW et les autres chaînes : ces règles ne prouvent pas la connectivité.\n'

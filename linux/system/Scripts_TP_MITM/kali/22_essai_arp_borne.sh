#!/usr/bin/env bash
# Usage : bash 22_essai_arp_borne.sh TP2[-suffixe]
# Uniquement client ↔ FreeSCO : 180 secondes, 60 secondes au TP5.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; session "${1:-}"; need arpspoof timeout pgrep ss
pgrep -x arpspoof >/dev/null && die 'Un arpspoof est déjà actif.'
[[ "$(sysctl -n net.ipv4.ip_forward)" == 1 ]] || die 'Relais IPv4 inactif.'
[[ "$(cat "/sys/class/net/$IFACE/address")" == "$KALI_MAC" ]] || die 'MAC Kali différente de la référence.'
if [[ "$TP" == TP3 || "$TP" == TP4 ]]; then
 ss -H -lnt 'sport = :8080' | grep -Fq "$KALI:8080" || die 'Proxy absent sur KALI:8080.'
fi
seconds=180; [[ "$TP" != TP5 ]] || seconds=60
sudo -v
printf 'Essai ciblé : %s ↔ %s sur %s, %s s maximum.\n' "$CLIENT" "$GW" "$IFACE" "$seconds"
code=0
sudo timeout --signal=INT --kill-after=10s "${seconds}s" arpspoof -i "$IFACE" -t "$CLIENT" -r "$GW" \
  2>&1 | tee "$REF/ARP_$(date +%H%M%S)_$$.log" || code=$?
case "$code" in 0|124|130) ;; *) die "Essai interrompu en erreur ($code). Restaurer et vérifier les caches.";; esac
printf 'Essai arrêté. Vérifier les caches client ET FreeSCO ; aucune réussite n’est déduite du délai.\n'

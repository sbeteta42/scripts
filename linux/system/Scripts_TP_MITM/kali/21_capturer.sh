#!/usr/bin/env bash
# Usage : bash 21_capturer.sh TP2[-suffixe] ; terminal capture séparé.
# Arrêt automatique à 240 s ; Ctrl+C plus tôt. PCAP sans clés TLS.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; session "${1:-}"; need tcpdump timeout; sudo -v
if [[ "$TP" == TP2 || "$TP" == TP5 ]]; then
 filter="arp or (host $CLIENT and host $WEB)"
else
 filter="arp or ((host $CLIENT or host $KALI) and host $WEB and (tcp port 80 or tcp port 443))"
fi
case "$TP" in TP2) name=TP2_MITM;; TP3) name=TP3_HTTP;; TP4) name=TP4_HTTPS;; TP5) name=TP5_PROTECTION;; esac
out="$REF/$name.pcap"; [[ ! -e "$out" ]] || die 'Capture existante : ne pas l’écraser.'
printf '%s\n' "$filter" > "$REF/filtre_capture.txt"
# -Z remet les droits au compte apprenant après ouverture de l’interface par root.
code=0
sudo timeout --signal=INT --kill-after=10s 240s tcpdump -Z "$(id -un)" -i "$IFACE" -e -s 0 -U -w "$out" "$filter" || code=$?
case "$code" in 0|124|130) ;; *) die "tcpdump a échoué : $code";; esac
sha256sum "$out" | tee "$out.sha256"

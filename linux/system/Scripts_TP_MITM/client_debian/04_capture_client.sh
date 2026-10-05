#!/usr/bin/env bash
# Usage : bash 04_capture_client.sh TP1|TP4|TP5
# PCAPNG pour Wireshark. Droits dumpcap/capture préparés avant la séance.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role client; need dumpcap
tp="${1:-}"; [[ "$tp" =~ ^TP[145]$ ]] || die 'Usage : TP1 | TP4 | TP5'
out="$LAB_DIR/preuves/${tp}_client_$(date +%Y%m%d_%H%M%S)_$$.pcapng"
dumpcap -i "$CLIENT_IFACE" -a duration:240 -s 0 -f "arp or (host $CLIENT and host $WEB)" -w "$out"
sha256sum "$out" > "$out.sha256"

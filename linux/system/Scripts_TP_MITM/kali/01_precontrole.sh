#!/usr/bin/env bash
# Contrôle sans installation, sans modification du pare-feu.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali
need macchanger arpspoof mitmproxy mitmdump iptables iptables-save timeout sysctl tcpdump openssl ss awk
sudo -v
f="$LAB_DIR/preuves/precontrole_$(date +%Y%m%d_%H%M%S)_$$.txt"
{
 date -Is; ip -br addr; ip route; ip route get "$WEB"
 macchanger --version; mitmproxy --version; curl --version; sudo iptables --version
 # arpspoof -h renvoie habituellement un code non nul : c’est l’aide, pas un test réussi.
 arpspoof -h 2>&1 || true
 sudo iptables -S; sudo iptables -t nat -S
 if command -v nft >/dev/null; then sudo nft list ruleset; fi
 sysctl_snapshot; ip neigh show dev "$IFACE"
} | tee "$f"
mitmproxy --options > "$LAB_DIR/preuves/options_disponibles.txt"
for option in confdir ssl_insecure ssl_verify_upstream_trusted_ca; do
 grep -q "^${option}:" "$LAB_DIR/preuves/options_disponibles.txt" || die "Option proxy absente : $option"
done
printf 'Contrôler dans VMware : LAN distinct, une carte Kali/client, aucun bridge, instantanés.\n'
printf 'Le script ne peut pas prouver l’isolation VMware ni la configuration de FreeSCO.\n'

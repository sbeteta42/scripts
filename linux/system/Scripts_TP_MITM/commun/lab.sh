#!/usr/bin/env bash
# Fonctions communes : charger ce fichier, ne pas le lancer seul.
# Les fichiers .env sont produits par les scripts 00 et appartiennent à l'utilisateur.
# par sbeteta@beteta.org
set -Eeuo pipefail
umask 077
LAB_DIR="$HOME/lab-mitm"
die() { printf 'ERREUR : %s\n' "$*" >&2; exit 1; }
need() { local c; for c in "$@"; do command -v "$c" >/dev/null || die "Outil absent : $c"; done; }
user_only() { (( EUID != 0 )) || die 'Lancer avec votre compte habituel ; les commandes privilégiées utilisent sudo.'; }
private_ip() {
  python3 - "$@" <<'PY'
import ipaddress, sys
zones=[ipaddress.ip_network(n) for n in ('10.0.0.0/8','172.16.0.0/12','192.168.0.0/16')]
for value in sys.argv[1:]:
    try: ip=ipaddress.IPv4Address(value)
    except ValueError: raise SystemExit('IPv4 invalide : '+value)
    if not any(ip in n for n in zones): raise SystemExit('IPv4 hors des réseaux privés du TP : '+value)
PY
}
valid_mac() {
 [[ "$1" =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]] || die 'MAC invalide ; utiliser xx:xx:xx:xx:xx:xx.'
 python3 - "$1" <<'PY'
import sys
b=bytes.fromhex(sys.argv[1].replace(':',''))
if not any(b) or b[0]&1: raise SystemExit('MAC nulle ou multicast : relever la MAC unicast sur la console.')
PY
}
load_role() {
  user_only; need python3 ip curl sha256sum
  local f="$LAB_DIR/$1.env"
  [[ -f "$f" && -O "$f" ]] || die "Paramètres absents ou non possédés : $f"
  # Source locale explicitement générée par 00_configuration, jamais un téléchargement.
  source "$f"
  private_ip "$WEB"
  if [[ "$1" == kali ]]; then
    private_ip "$KALI" "$CLIENT" "$GW"; valid_mac "$GW_MAC"; valid_mac "$CLIENT_MAC"; valid_mac "$KALI_MAC"
    check_interface "$IFACE" "$KALI" "$GW" "$CLIENT"
    python3 - "$KALI" "$CLIENT" "$GW" "$WEB" <<'PY'
import sys
if len(set(sys.argv[1:])) != 4: raise SystemExit('Les quatre IP doivent être différentes.')
PY
  elif [[ "$1" == client ]]; then
    private_ip "$CLIENT" "$GW"; valid_mac "$GW_MAC"
    check_interface "$CLIENT_IFACE" "$CLIENT" "$GW"
  fi
  mkdir -p "$LAB_DIR/preuves"
}
check_interface() {
  local iface="$1" iplocal="$2" gateway="$3" peer="${4:-}"
  [[ "$iface" =~ ^[a-zA-Z0-9_-]+$ && -d "/sys/class/net/$iface" ]] || die 'Interface absente ou nom non pris en charge.'
  ip -j -4 address show dev "$iface" | python3 -c '
import json,ipaddress,sys
a=json.load(sys.stdin); local,gw,web,peer=sys.argv[1:]
matches=[x for i in a for x in i.get("addr_info",[]) if x.get("local")==local]
if not matches: raise SystemExit("IP locale différente des paramètres ; contrôler DHCP.")
n=ipaddress.ip_network(local+"/"+str(matches[0]["prefixlen"]),strict=False)
if ipaddress.ip_address(gw) not in n: raise SystemExit("Passerelle hors du LAN.")
if ipaddress.ip_address(web) in n: raise SystemExit("WEB doit être sur le WAN de test, hors du LAN.")
if peer and ipaddress.ip_address(peer) not in n: raise SystemExit("Le client doit être dans le LAN Kali/FreeSCO.")
' "$iplocal" "$gateway" "$WEB" "$peer"
  ip -j route get "$WEB" | python3 -c '
import json,sys
r=json.load(sys.stdin)[0]
if r.get("dev")!=sys.argv[1] or r.get("gateway")!=sys.argv[2]:
    raise SystemExit("La route vers WEB ne passe pas par la carte LAN et FreeSCO.")
' "$iface" "$gateway"
}
hash_check() {
  local file="$1" expected="${2,,}" actual
  [[ "$expected" =~ ^[a-f0-9]{64}$ ]] || die 'Fournir le SHA-256 de 64 caractères obtenu sur la console de référence.'
  [[ -r "$file" ]] || die "Certificat absent : $file"
  actual=$(sha256sum "$file"); actual=${actual%% *}
  [[ "$actual" == "$expected" ]] || die "Empreinte incorrecte pour $file"
  printf 'SHA-256 validé : %s\n' "$actual"
}
assert_server_cert() {
  [[ -r "$LAB_DIR/serveur.sha256" ]] || die 'Valider serveur.crt avec 02_certificat_direct.sh.'
  hash_check "$LAB_DIR/serveur.crt" "$(cat "$LAB_DIR/serveur.sha256")"
  need openssl
  openssl x509 -in "$LAB_DIR/serveur.crt" -noout -checkend 0 >/dev/null || die 'Certificat expiré.'
  openssl verify -CAfile "$LAB_DIR/serveur.crt" -verify_ip "$WEB" "$LAB_DIR/serveur.crt"
}
assert_idle() {
  need pgrep
  local p
  for p in arpspoof mitmproxy mitmdump tcpdump; do
    if pgrep -x "$p" >/dev/null; then pgrep -a -x "$p" >&2; die "Arrêter $p dans son terminal avant cette opération."; fi
  done
}
session() {
  local id="${1:-}"
  [[ "$id" =~ ^TP[2345](-[A-Za-z0-9_-]+)?$ ]] || die 'Identifiant attendu : TP2, TP3, TP4, TP5 ou TP4-neg, etc.'
  REF="$LAB_DIR/preuves/$id"; TP="${id%%-*}"
  [[ -f "$REF/kali.env" ]] || die "Référence absente : $REF"
  cmp -s "$LAB_DIR/kali.env" "$REF/kali.env" || die 'Paramètres différents de la référence ; remettre le fichier initial.'
  [[ -r "$LAB_DIR/essai_actif" && "$(cat "$LAB_DIR/essai_actif")" == "$id" ]] || die 'Cet essai n’est pas actif.'
}
sysctl_snapshot() {
  sysctl net.ipv4.ip_forward
  local zone cle
  for zone in all default "$IFACE"; do
    for cle in rp_filter accept_redirects send_redirects; do sysctl "net.ipv4.conf.$zone.$cle"; done
  done
}
validate_sysctl() {
  # Valide les noms ET les dix valeurs, dans l’ordre imposé par la restauration.
  python3 - "$1" "$IFACE" <<'PY'
from pathlib import Path
import sys,re
keys=['net.ipv4.ip_forward']+[f'net.ipv4.conf.{z}.{c}' for z in ('all','default',sys.argv[2]) for c in ('rp_filter','accept_redirects','send_redirects')]
lines=Path(sys.argv[1]).read_text().splitlines()
if len(lines)!=10: raise SystemExit('Référence sysctl incomplète.')
for key,line in zip(keys,lines):
    if not re.fullmatch(re.escape(key)+r' = [0-2]',line): raise SystemExit('Référence sysctl invalide : '+line)
PY
}
bounded() {
  # Ctrl+C ou fin du délai = fin normale de la fenêtre, pas preuve de succès du TP.
  local seconds="$1"; shift
  local code=0
  timeout --signal=INT --kill-after=10s "${seconds}s" "$@" || code=$?
  case "$code" in 0|124|130) return 0;; *) return "$code";; esac
}
curl_test() {
  local label="$1" url="$2" ca="${3:-}" expected="${4:-success}" code=0
  local base="$LAB_DIR/preuves/${label}_$(date +%Y%m%d_%H%M%S)_$$"
  local args=(--noproxy '*' --http1.1 --max-time 10 --fail --show-error)
  [[ -z "$ca" ]] || args+=(--cacert "$ca")
  curl "${args[@]}" "$url" > "$base.corps.txt" 2> "$base.erreur.txt" || code=$?
  printf '%s\n' "$code" > "$base.code.txt"
  cat "$base.corps.txt"; cat "$base.erreur.txt" >&2
  if [[ "$expected" == tls-refusal ]]; then
    [[ "$code" == 60 ]] || die "Refus TLS attendu ; code réel $code. Lire le message : un timeout ne prouve rien."
    printf 'curl signale un défaut de validation du certificat ; corréler au proxy.\n'
  else
    (( code == 0 )) || die "Échec curl ($code), traces : $base.*"
    grep -q 'MESSAGE_FICTIF_MITM_2026' "$base.corps.txt" || die 'Marqueur pédagogique absent.'
  fi
}

#!/usr/bin/env bash
# Usage : bash 30_proxy_transparent.sh TP3|TP4[-suffixe] [interface|journal|amont-negatif]
# Mode négatif : formateur uniquement, TP4, CA amont volontairement incorrecte.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; session "${1:-}"; assert_server_cert; need mitmproxy mitmdump timeout ss
[[ "$TP" == TP3 || "$TP" == TP4 ]] || die 'Proxy réservé aux TP3 et TP4.'
ss -H -lnt 'sport = :8080' | grep -q . && die 'Port 8080 déjà utilisé.'
mode="${2:-interface}"; binary=mitmproxy; ca="$LAB_DIR/serveur.crt"
case "$mode" in
 interface) ;;
 journal) binary=mitmdump;;
 amont-negatif)
  [[ "$TP" == TP4 ]] || die 'Contrôle négatif réservé au TP4.'
  binary=mitmdump; ca="$REF/ca_amont_incorrecte.crt"
  # Créer une autre CA : sa clé n’est ni partagée ni conservée.
  tmp=$(mktemp -d "$LAB_DIR/negative.XXXXXX"); trap 'rm -rf "$tmp"' EXIT
  openssl req -x509 -newkey rsa:2048 -nodes -days 2 -subj '/CN=CA non approuvee test negatif' \
   -addext 'basicConstraints=critical,CA:TRUE' -keyout "$tmp/ca.key" -out "$ca"
  rm -rf "$tmp"; trap - EXIT
  printf 'Validation amont doit échouer ; relever l’erreur TLS dans le journal, pas seulement un 502.\n';;
 *) die 'Mode attendu : interface | journal | amont-negatif';;
esac
confdir="$LAB_DIR/mitm-ca-lab"; mkdir -p "$confdir"; chmod 700 "$confdir"
out="$REF/${TP}_$( [[ "$TP" == TP3 ]] && printf HTTP || printf HTTPS ).mitm"
[[ ! -e "$out" ]] || die 'Flux existant : refaire un essai avec une nouvelle référence.'
args=(--mode transparent --listen-host "$KALI" --listen-port 8080
 --set "confdir=$confdir" --set "ssl_verify_upstream_trusted_ca=$ca"
 --set ssl_insecure=false -w "$out")
"$binary" "${args[@]}" --options > "$REF/options_proxy_effectives.txt"
grep -Eq '^ssl_insecure: false$' "$REF/options_proxy_effectives.txt" || die 'Validation amont désactivée ou option incompatible.'
printf 'Commande : '; printf '%q ' "$binary" "${args[@]}"; printf '\n'
if [[ "$binary" == mitmdump ]]; then
 bounded 240 "$binary" "${args[@]}" -vv 2>&1 | tee "$REF/proxy_journal.log"
else
 bounded 240 "$binary" "${args[@]}"
fi
printf 'Proxy arrêté ; conserver les flux et restaurer l’essai.\n'

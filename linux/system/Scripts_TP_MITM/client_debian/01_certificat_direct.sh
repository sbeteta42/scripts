#!/usr/bin/env bash
# Usage : bash 01_certificat_direct.sh SHA256_CONSOLE_FORMATEUR
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role client
tmp=$(mktemp "$LAB_DIR/serveur.XXXXXX"); trap 'rm -f "$tmp"' EXIT
curl --noproxy '*' --fail --show-error --max-time 10 "http://$WEB/serveur.crt" -o "$tmp"
hash_check "$tmp" "${1:-}"
mv "$tmp" "$LAB_DIR/serveur.crt"
printf '%s\n' "${1,,}" > "$LAB_DIR/serveur.sha256"
assert_server_cert
curl_test HTTP_direct "http://$WEB/index.html"
curl_test HTTPS_direct "https://$WEB/index.html" "$LAB_DIR/serveur.crt"

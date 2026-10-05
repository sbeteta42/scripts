#!/usr/bin/env bash
# Usage : bash 02_certificat_direct.sh SHA256_ANNONCE_PAR_LE_FORMATEUR
# À exécuter hors interception ; seul le certificat PUBLIC est téléchargé.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; assert_idle
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Restaurer le réseau avant les tests directs.'
expected="${1:-}"; tmp=$(mktemp "$LAB_DIR/serveur.XXXXXX")
trap 'rm -f "$tmp"' EXIT
curl --noproxy '*' --fail --show-error --max-time 10 "http://$WEB/serveur.crt" -o "$tmp"
hash_check "$tmp" "$expected"
mv "$tmp" "$LAB_DIR/serveur.crt"
printf '%s\n' "${expected,,}" > "$LAB_DIR/serveur.sha256"
assert_server_cert
openssl x509 -in "$LAB_DIR/serveur.crt" -noout -dates -subject -issuer -ext subjectAltName | tee "$LAB_DIR/preuves/certificat_serveur.txt"
curl_test HTTP_direct "http://$WEB/index.html"
curl_test HTTPS_direct "https://$WEB/index.html" "$LAB_DIR/serveur.crt"

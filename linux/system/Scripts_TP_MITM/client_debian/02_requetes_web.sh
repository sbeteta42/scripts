#!/usr/bin/env bash
# Usage : bash 02_requetes_web.sh http|https-direct|https-refus|https-proxy [SHA256_CA_KALI]
# Conserve corps, stderr et code curl. Aucun certificat installé au niveau système.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role client
case "${1:-}" in
 http) curl_test HTTP "http://$WEB/index.html?module=MITM&message=EXERCICE";;
 https-direct) assert_server_cert; curl_test HTTPS_direct "https://$WEB/index.html" "$LAB_DIR/serveur.crt";;
 https-refus) assert_server_cert; curl_test HTTPS_refus "https://$WEB/index.html" "$LAB_DIR/serveur.crt" tls-refusal;;
 https-proxy)
  hash_check "$LAB_DIR/mitmproxy-ca-cert.pem" "${2:-}"
  grep -q 'PRIVATE KEY' "$LAB_DIR/mitmproxy-ca-cert.pem" && die 'CA privée interdite sur le client.'
  curl_test HTTPS_proxy "https://$WEB/index.html" "$LAB_DIR/mitmproxy-ca-cert.pem";;
 *) die 'Usage : http | https-direct | https-refus | https-proxy SHA256_CA_KALI';;
esac

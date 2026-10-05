#!/usr/bin/env bash
# Usage : bash 31_exporter_ca_publique.sh
# À lancer APRÈS le démarrage du proxy ; ne copie jamais mitmproxy-ca.pem.
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali
src="$LAB_DIR/mitm-ca-lab/mitmproxy-ca-cert.pem"
[[ -r "$src" ]] || die 'Démarrer le proxy avec le confdir prévu pour créer sa CA.'
grep -q 'PRIVATE KEY' "$src" && die 'Le fichier contient une clé privée : ne pas le partager.'
openssl x509 -in "$src" -noout -dates -subject
mkdir -p "$LAB_DIR/public"
cp "$src" "$LAB_DIR/public/mitmproxy-ca-cert.pem"
sha256sum "$LAB_DIR/public/mitmproxy-ca-cert.pem" | tee "$LAB_DIR/preuves/CA_proxy_SHA256.txt"
printf 'Copier seulement public/mitmproxy-ca-cert.pem dans lab-mitm sur le client.\n'
printf 'Comparer son SHA-256 directement à cette console Kali.\n'

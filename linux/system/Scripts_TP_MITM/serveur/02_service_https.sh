#!/usr/bin/env bash
# Terminal serveur HTTPS durable ; -WWW sert les fichiers du répertoire courant.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role serveur; need openssl ss
[[ -r "$LAB_DIR/prive/serveur.key" ]] || die 'Clé serveur absente.'
openssl verify -CAfile "$LAB_DIR/site/serveur.crt" -verify_ip "$WEB" "$LAB_DIR/site/serveur.crt"
ss -H -lnt 'sport = :443' | grep -q . && die 'Port 443 occupé.'
cd "$LAB_DIR/site"
sudo openssl s_server -accept "$WEB:443" -cert "$LAB_DIR/site/serveur.crt" \
 -key "$LAB_DIR/prive/serveur.key" -WWW

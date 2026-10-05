#!/usr/bin/env bash
# Terminal serveur HTTP durable ; arrêt Ctrl+C en fin de séance.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role serveur; need python3 ss
[[ -r "$LAB_DIR/site/index.html" ]] || die 'Préparer le serveur.'
ss -H -lnt 'sport = :80' | grep -q . && die 'Port 80 occupé.'
sudo -v
# Servir uniquement site/ ; les clés privées sont dans prive/ et ne sont pas exposées.
sudo python3 -m http.server 80 --bind "$WEB" --directory "$LAB_DIR/site"

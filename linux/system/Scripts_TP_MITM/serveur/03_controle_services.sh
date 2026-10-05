#!/usr/bin/env bash
# Formateur : ports, horloge, certificat et marqueur réellement servi, sans ouvrir le pare-feu.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role serveur; need ss openssl
date -Is; sudo ss -lntp '( sport = :80 or sport = :443 )'
openssl x509 -in "$LAB_DIR/site/serveur.crt" -noout -dates -ext subjectAltName
curl_test serveur_HTTP "http://$WEB/index.html"
curl_test serveur_HTTPS "https://$WEB/index.html" "$LAB_DIR/site/serveur.crt"
printf 'Succès local seulement : vérifier aussi depuis Kali et le client à travers FreeSCO.\n'

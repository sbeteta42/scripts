#!/usr/bin/env bash
# Vérification finale de Kali ; les caches distants restent à contrôler en console.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role kali; assert_idle; assert_server_cert
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Essai encore actif.'
[[ "$(cat "/sys/class/net/$IFACE/address")" == "$KALI_MAC" ]] || die 'MAC Kali non rétablie.'
sudo iptables -t nat -S LAB_MITM >/dev/null 2>&1 && die 'Chaîne LAB_MITM restante.'
curl_test bilan_HTTP "http://$WEB/index.html"
curl_test bilan_HTTPS "https://$WEB/index.html" "$LAB_DIR/serveur.crt"
printf 'Kali : accès directs obtenus ; compléter les contrôles client et FreeSCO dans la fiche.\n'

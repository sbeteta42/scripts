#!/usr/bin/env bash
# Formateur après validation des preuves le 6 octobre : supprimer les clés du laboratoire.
# Usage : bash 99_supprimer_cles_temporaires.sh serveur|kali
# Conserve les preuves, pages, certificats PUBLICS et paramètres.
source "$(dirname "${BASH_SOURCE[0]}")/commun/lab.sh"
user_only; assert_idle; need ss
[[ ! -e "$LAB_DIR/essai_actif" ]] || die 'Restaurer l’essai actif avant de supprimer les clés.'
case "${1:-}" in
 serveur)
  [[ -z "$(ss -H -lnt '( sport = :80 or sport = :443 )')" ]] || die 'Arrêter les services HTTP et HTTPS avant suppression.'
  rm -f "$LAB_DIR/prive/serveur.key";;
 kali)
  # Fichiers standard contenant la clé privée CA dans le confdir réservé au TP.
  rm -f "$LAB_DIR/mitm-ca-lab/mitmproxy-ca.pem" "$LAB_DIR/mitm-ca-lab/mitmproxy-ca.p12";;
 *) die 'Usage : serveur | kali';;
esac
printf 'Clés privées standard supprimées. Les instantanés/sauvegardes peuvent encore les contenir.\n'
printf 'Un nouveau laboratoire exige une nouvelle génération et une nouvelle comparaison des empreintes.\n'

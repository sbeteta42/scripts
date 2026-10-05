#!/bin/sh
# Console FreeSCO. POSIX sh : pas de Bash, sudo, ip ou systemctl requis.
# sh controle_et_cache.sh observer
# sh controle_et_cache.sh proteger IP_CLIENT MAC_CLIENT
# sh controle_et_cache.sh restaurer IP_CLIENT
# Valeurs réelles relevées sur console. La syntaxe arp dépend de cette version FreeSCO.
# par sbeteta@beteta.org
set -eu
fail() { echo "ERREUR : $*" >&2; exit 1; }
valid_ip() {
 echo "$1" | awk -F. '
 NF!=4 {exit 1}
 {for(i=1;i<=4;i++) if($i!~/^[0-9]+$/ || $i<0 || $i>255) exit 1;
 if(!($1==10 || ($1==172 && $2>=16 && $2<=31) || ($1==192 && $2==168))) exit 1}' || fail 'IPv4 privée invalide.'
}
command -v arp >/dev/null 2>&1 || fail 'arp absent : noter la limite.'
case "${1:-}" in
 observer) date; ifconfig; route -n; arp -n;;
 proteger)
  [ "$#" -eq 3 ] || fail 'Usage : proteger IP_CLIENT MAC_CLIENT'
  valid_ip "$2"
  echo "$3" | awk -F: 'NF!=6 {exit 1} {for(i=1;i<=6;i++) if($i!~/^[0-9a-fA-F][0-9a-fA-F]$/) exit 1}' || fail 'MAC invalide.'
  echo 'Arrêter la source ARP et vérifier la MAC client sur sa console avant cette commande.'
  # Refuser une entrée permanente préexistante : sortie arp -n au format net-tools.
  # Sur une autre implémentation, le formateur vérifie explicitement le cache avant la commande.
  arp -n
  arp -n | awk -v ip="$2" '$1==ip && $3 ~ /M/ {fixed=1} END {exit !fixed}' && fail 'Entrée permanente préexistante : ne pas écraser.'
  arp -s "$2" "$3" || fail 'arp -s non pris en charge ; protection retour non démontrée.'
  arp -n;;
 restaurer)
  [ "$#" -eq 2 ] || fail 'Usage : restaurer IP_CLIENT'
  valid_ip "$2"
  echo 'Retirer uniquement cette entrée de laboratoire, après arrêt de la source.'
  arp -d "$2" || fail 'Suppression refusée/entrée absente : lire le message et contrôler le cache.'
  arp -n
  echo 'Provoquer ensuite un accès HTTP depuis le client ; vérifier que son IP retrouve sa MAC console.';;
 *) fail 'Usage : observer | proteger IP_CLIENT MAC_CLIENT | restaurer IP_CLIENT';;
esac

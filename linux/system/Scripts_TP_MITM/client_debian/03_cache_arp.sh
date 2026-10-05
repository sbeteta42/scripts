#!/usr/bin/env bash
# Usage : bash 03_cache_arp.sh observer|proteger|restaurer
# Supprime seulement GW, jamais le cache complet. Protection temporaire TP5.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
load_role client
marker="$LAB_DIR/protection_client_active"
log="$LAB_DIR/preuves/cache_$(date +%Y%m%d_%H%M%S)_$$.txt"
show() { ip neigh show to "$GW" dev "$CLIENT_IFACE" | tee -a "$log"; }
case "${1:-}" in
 observer) show;;
 proteger)
  [[ ! -e "$marker" ]] || die 'Protection de cet exercice déjà active.'
  show
  # Ne pas écraser une association permanente préexistante administrée ailleurs.
  ip neigh show to "$GW" dev "$CLIENT_IFACE" | grep -Eq 'PERMANENT|NOARP' && die 'Entrée fixe préexistante : consulter le formateur.'
  sudo -v; touch "$marker"
  sudo ip neigh replace "$GW" lladdr "$GW_MAC" nud permanent dev "$CLIENT_IFACE"
  show
  ip neigh show to "$GW" dev "$CLIENT_IFACE" | grep -qi 'PERMANENT' || die 'État permanent non obtenu.'
  ;;
 restaurer)
  entry=$(ip neigh show to "$GW" dev "$CLIENT_IFACE")
  if [[ "$entry" =~ PERMANENT|NOARP && ! -e "$marker" ]]; then die 'Association fixe sans témoin du TP : ne pas la supprimer.'; fi
  sudo -v
  [[ -z "$entry" ]] || sudo ip neigh del "$GW" dev "$CLIENT_IFACE"
  rm -f "$marker"
  curl_test ARP_reconstruction "http://$WEB/index.html"
  show
  actual=$(ip neigh show to "$GW" dev "$CLIENT_IFACE" | awk '{for(i=1;i<=NF;i++) if($i=="lladdr") print $(i+1)}')
  [[ "${actual,,}" == "${GW_MAC,,}" ]] || die 'Passerelle associée à une MAC différente de la console FreeSCO.'
  ;;
 *) die 'Usage : observer | proteger | restaurer';;
esac

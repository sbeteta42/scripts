#!/usr/bin/env bash
# Usage : bash 90_restaurer_essai.sh TP2[-suffixe]
# Peut être relancé après une interruption. Ne recharge jamais tout le pare-feu.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
# On autorise une récupération même si DHCP a changé l’IP : ne pas appeler load_role.
user_only; need sudo iptables sysctl python3 sha256sum
[[ -r "$LAB_DIR/kali.env" ]] || die 'Paramètres Kali absents.'
source "$LAB_DIR/kali.env"; session "${1:-}"; assert_idle; sudo -v
sha256sum -c "$REF/references.sha256"
validate_sysctl "$REF/sysctl_avant.conf"
if [[ -f "$REF/nat_saut_possede" ]]; then
 if sudo iptables -t nat -C PREROUTING -i "$IFACE" -s "$CLIENT" -d "$WEB" -j LAB_MITM 2>/dev/null; then
  sudo iptables -t nat -D PREROUTING -i "$IFACE" -s "$CLIENT" -d "$WEB" -j LAB_MITM
 fi
fi
if [[ -f "$REF/nat_chaine_possedee" ]] && sudo iptables -t nat -S LAB_MITM >/dev/null 2>&1; then
 # Effacer seulement la règle exacte de cet essai ; tout ajout inconnu bloque -X.
 port=80; [[ "$TP" != TP4 ]] || port=443
 if sudo iptables -t nat -C LAB_MITM -p tcp --dport "$port" -j REDIRECT --to-ports 8080 2>/dev/null; then
  sudo iptables -t nat -D LAB_MITM -p tcp --dport "$port" -j REDIRECT --to-ports 8080
 fi
 sudo iptables -t nat -X LAB_MITM
fi
if [[ -f "$REF/filter_exceptions_possedees" ]]; then
 bash "$(dirname "${BASH_SOURCE[0]}")/23_regles_flux_optionnelles.sh" "$1" retirer
fi
# ip_forward est la première ligne ; les neuf autres valeurs viennent ensuite.
sudo sysctl -p "$REF/sysctl_avant.conf"
sysctl_snapshot > "$REF/sysctl_apres.conf"
diff -u "$REF/sysctl_avant.conf" "$REF/sysctl_apres.conf" > "$REF/ecarts_sysctl_cibles.diff" || die 'Valeurs sysctl ciblées non rétablies.'
sudo iptables-save > "$REF/iptables_apres.txt"
# Les en-têtes de date iptables-save changent : comparer les lignes non commentées.
diff -u <(grep -v '^#' "$REF/iptables_avant.txt") <(grep -v '^#' "$REF/iptables_apres.txt") \
 > "$REF/ecarts_pare_feu.diff" || die 'Pare-feu différent : retirer exactement les exceptions ajoutées par le formateur puis relancer.'
sudo sysctl -a -e > "$REF/sysctl_complet_apres.txt" 2> "$REF/sysctl_apres_avertissements.txt"
diff -u <(LC_ALL=C sort "$REF/sysctl_complet_avant.txt") <(LC_ALL=C sort "$REF/sysctl_complet_apres.txt") \
 > "$REF/ecarts_sysctl_complets.diff" || true
if command -v nft >/dev/null && [[ -f "$REF/nft_avant.txt" ]]; then
 sudo nft list ruleset > "$REF/nft_apres.txt"
 diff -u "$REF/nft_avant.txt" "$REF/nft_apres.txt" > "$REF/ecarts_nft.diff" || true
fi
date -Is > "$REF/restauration_kali.txt"
rm "$LAB_DIR/essai_actif"
printf 'Règles de cet essai retirées et dix valeurs sysctl comparées.\n'
printf 'Examiner les autres écarts (dont compteurs nft) ; instantané si le retour complet est requis.\n'
printf 'Il reste à reconstruire les caches client/FreeSCO, vérifier leurs MAC et tester HTTP/HTTPS directs.\n'

#!/usr/bin/env bash
# Formateur, avant 09 h : IP réelle, page fictive, certificat pour cette IP.
# CA:TRUE cumule certificat de service et ancre de laboratoire, sans PKI de production.
# par sbeteta@beteta.org
source "$(dirname "${BASH_SOURCE[0]}")/../commun/lab.sh"
user_only; need ip python3 openssl ss
mkdir -p "$LAB_DIR"
[[ ! -e "$LAB_DIR/serveur.env" && ! -e "$LAB_DIR/prive/serveur.key" ]] || die 'Référence serveur existante : conserver ou purger après validation, ne pas écraser.'
ip -br addr; ip route; date -Is
read -r -p 'IPv4 réelle serveur sur le WAN de test, fixe hors du pool DHCP : ' WEB
private_ip "$WEB"
ip -j -4 addr | python3 -c 'import json,sys; a=json.load(sys.stdin); assert any(x.get("local")==sys.argv[1] for i in a for x in i.get("addr_info",[])), "IP absente du serveur"' "$WEB"
[[ -z "$(ss -H -lnt '( sport = :80 or sport = :443 )')" ]] || die 'Port 80 ou 443 déjà utilisé.'
printf 'WEB=%q\n' "$WEB" > "$LAB_DIR/serveur.env"
mkdir -p "$LAB_DIR/site" "$LAB_DIR/prive" "$LAB_DIR/preuves"
chmod 700 "$LAB_DIR/prive"
cat > "$LAB_DIR/site/index.html" <<'HTML'
<!doctype html><html lang="fr"><meta charset="utf-8"><title>Laboratoire MITM</title>
<h1>Laboratoire pédagogique MITM</h1><p>MESSAGE_FICTIF_MITM_2026</p>
<p>Données fictives : aucun identifiant réel.</p></html>
HTML
# Validité 48 h à partir de maintenant : pour le 6 octobre, créer le 5 ou le 6.
# La clé privée est HORS du répertoire HTTP/HTTPS.
openssl req -x509 -newkey rsa:2048 -nodes -days 2 -subj '/CN=lab-mitm.test' \
 -addext "subjectAltName=DNS:lab-mitm.test,IP:$WEB" \
 -addext 'basicConstraints=critical,CA:TRUE' \
 -keyout "$LAB_DIR/prive/serveur.key" -out "$LAB_DIR/site/serveur.crt"
chmod 600 "$LAB_DIR/prive/serveur.key"
openssl x509 -in "$LAB_DIR/site/serveur.crt" -noout -dates -subject -issuer -ext subjectAltName | tee "$LAB_DIR/preuves/certificat_serveur.txt"
sha256sum "$LAB_DIR/site/serveur.crt" | tee "$LAB_DIR/preuves/SHA256_serveur.txt"
printf 'Annoncer le SHA-256 depuis cette console. Ne distribuer que serveur.crt.\n'
printf 'Lancer 01_service_http.sh et 02_service_https.sh dans deux terminaux durables.\n'

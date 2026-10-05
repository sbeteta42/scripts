# Scripts séparés — TP MITM et ARP spoofing

Support : TP apprenant corrigé le 4 octobre 2026, « MITM_TP_Apprenants(2).docx », et fiche de contrôle du laboratoire du 6 octobre. Formation Stéphane Beteta — https://formation.beteta.org

Les cinq TP se déroulent de 14 h à 17 h 15, après les contrôles de 12 h à 13 h. Séance : 09–13 h et 14–18 h. Ces scripts reprennent les opérations du support. Ils n’utilisent pas Open vSwitch.

**État de validation : syntaxe Bash/POSIX et contrôles locaux effectués ; aucun essai sur vos VM réelles. PowerShell a fait l’objet d’une revue, sans exécution sous Windows.** Les contrôles réseau, hyperviseur, curl/Schannel, droits de capture et version FreeSCO doivent être consignés sur la fiche.

## 1. Organisation et préparation

Décompresser le ZIP complet sur chaque VM qui en a besoin. Conserver les sous-dossiers : les scripts Linux chargent `../commun/lab.sh`, les scripts Windows chargent `Commun.ps1`. Tous les scripts sont commentés. Les paramètres et preuves restent locaux à chaque VM, dans `~/lab-mitm` ou `%USERPROFILE%\lab-mitm`. Le script recharge lui-même les paramètres à chaque lancement.

Sur Linux, lancer **sans sudo devant bash** : le compte habituel détermine le bon HOME et le confdir du proxy. Les opérations root demandent sudo individuellement. Ne pas installer les dépendances pendant les TP.

| Rôle | Dépendances à préparer |
|---|---|
| Kali | Bash, Python 3, iproute2, procps, coreutils, diffutils, awk, grep, sudo, macchanger, dsniff/arpspoof, tcpdump, mitmproxy et mitmdump, iptables/iptables-save, OpenSSL, curl ; nft si utilisé |
| Debian client | Bash, Python 3, iproute2, coreutils, awk, grep, sudo, curl, OpenSSL ; dumpcap et droits de capture pour le script 04 |
| Windows client | PowerShell administrateur, cmdlets NetTCPIP/NetAdapter, curl.exe compatible `--cacert` ; Wireshark/Npcap pour le script 04 |
| Serveur Linux | Bash, Python 3, OpenSSL avec `-addext` et `-WWW`, iproute2, curl, sudo |
| FreeSCO | Console locale, sh, awk, ifconfig, route, arp ; vérifier `arp -s` et `arp -d` selon la version |

Préparer les instantanés. Un LAN virtuel distinct par binôme sur un même hôte ; un seul adaptateur LAN pour Kali et le client, deux adaptateurs LAN/WAN pour FreeSCO. Aucun bridge. VMnet8 de deux hôtes ne représente pas automatiquement le même WAN. Vérifier le serveur de test à IP fixe, hors pool DHCP/NAT, et le NAT/routage FreeSCO.

Les scripts refusent les IPv4 hors des plages RFC1918 et les routes client/Kali ne passant pas par FreeSCO. Cela ne remplace pas le contrôle de l’isolement dans VMware. Les valeurs du document (`.1`, `.10`, `.11`, `172.16.42.50`) sont des exemples ; aucune n’est imposée.

## 2. Serveur pédagogique — formateur, avant 09 h

Depuis la racine du pack :

```bash
bash serveur/00_preparer_serveur.sh
```

Saisir l’IP WAN réelle. La clé est créée dans `~/lab-mitm/prive/serveur.key`, **hors** du répertoire web. `site/` contient seulement la page fictive et `serveur.crt`. Le SHA-256 s’affiche sur la console du formateur ; l’annoncer par ce canal de référence aux apprenants.

Deux terminaux durables, puis un troisième de contrôle :

```bash
# Terminal serveur 1
bash serveur/01_service_http.sh
# Terminal serveur 2
bash serveur/02_service_https.sh
# Terminal serveur 3
bash serveur/03_controle_services.sh
```

Le certificat est valide 48 heures à partir de sa génération. Pour la séance du 6 octobre, le générer le 5 ou le 6 et vérifier les horloges, dates et SAN. Celui du 4 octobre ne doit pas être supposé valable jusqu’à la fin de la séance. CA:TRUE cumule les rôles de service et d’ancre de laboratoire. Si l’IP change, régénérer et redistribuer son empreinte. Ces scripts ne configurent ni FreeSCO, ni les réseaux VMware, ni le pare-feu du serveur.

## 3. Paramètres et accès directs — de 12 h à 13 h

Kali :

```bash
bash kali/00_configuration.sh
bash kali/01_precontrole.sh
bash kali/02_certificat_direct.sh SHA256_LU_SUR_CONSOLE_FORMATEUR
```

Windows (PowerShell administrateur, depuis la racine du pack) :

```powershell
.\client_windows\00_Configuration.ps1
.\client_windows\01_Certificat_Direct.ps1 -SHA256 SHA256_LU_SUR_CONSOLE_FORMATEUR
```

Debian, si ce client remplace Windows :

```bash
bash client_debian/00_configuration.sh
bash client_debian/01_certificat_direct.sh SHA256_LU_SUR_CONSOLE_FORMATEUR
```

Remplacer les textes `SHA256_...` par les 64 caractères du hash réellement annoncé. Ne pas les saisir littéralement. Le téléchargement HTTP du certificat n’est accepté qu’après comparaison de cette empreinte. Les appels directs doivent afficher `MESSAGE_FICTIF_MITM_2026`. Une erreur de route/DHCP bloque : corriger la VM et conserver les valeurs de référence, ne pas forcer le contrôle.

Si Windows bloque l’exécution des `.ps1`, appliquer la politique autorisée de l’établissement. Après revue du fichier téléchargé, `Unblock-File` peut lever son marquage Internet ; aucun script ne change la politique d’exécution. Sur Debian, le script de capture demande les droits dumpcap préparés par le formateur.

## 4. TP1 — 14 h à 14 h 30

Dans un terminal client, démarrer la capture ; dans un autre, reconstruire l’entrée passerelle et effectuer l’accès HTTP :

```powershell
.\client_windows\04_Capture_Client.ps1 -TP TP1
# Dans un autre terminal :
.\client_windows\03_Cache_ARP.ps1 -Action restaurer
```

Alternative Debian :

```bash
bash client_debian/04_capture_client.sh TP1
# Dans un autre terminal :
bash client_debian/03_cache_arp.sh restaurer
```

Kali **depuis sa console VMware locale** :

```bash
bash kali/10_mac_temporaire.sh changer
```

Le script sauvegarde la MAC réellement utilisée, change la MAC, affiche IP/routes, puis attend Entrée pour la restaurer. Observer DHCP/connectivité avant de valider. Ctrl+C ou une erreur déclenche une tentative de restauration ; la sauvegarde reste conservée. En cas de terminal fermé ou récupération manuelle :

```bash
bash kali/10_mac_temporaire.sh restaurer
```

Ne pas remplacer cette restauration par `macchanger -p`. Recontrôler IP et route ; le script ne réattribue pas les adresses DHCP. `mac_avant.txt` n’est jamais écrasé automatiquement. La capture PCAPNG horodatée du client remplit le rôle de `TP1_reference.pcapng` du support.

## 5. TP2 — 14 h 30 à 15 h 15

Dans le terminal Kali de préparation :

```bash
bash kali/20_preparer_essai.sh TP2
```

Dans un terminal Kali capture :

```bash
bash kali/21_capturer.sh TP2
```

Dans un terminal Kali essai :

```bash
bash kali/22_essai_arp_borne.sh TP2
```

Pendant les 180 secondes, sur le client :

```powershell
.\client_windows\03_Cache_ARP.ps1 -Action observer
.\client_windows\02_Requetes_Web.ps1 -Mode http
```

Ou sur Debian :

```bash
bash client_debian/03_cache_arp.sh observer
bash client_debian/02_requetes_web.sh http
```

Sur FreeSCO : `sh controle_et_cache.sh observer` après copie de ce script sur la VM. Comparer les MAC aux consoles et corréler les trames aller/retour au marqueur HTTP. Le démarrage des outils ne démontre pas une interception.

Fin : arrêter la capture par Ctrl+C, vérifier que l’essai ARP est arrêté, puis appliquer la procédure de restauration (§9). Un nouveau passage utilise un identifiant comme `TP2-bis` **après** restauration ; ne jamais écraser `TP2`.

## 6. TP3 — 15 h 15 à 16 h

Après retour à l’état sain du TP2 :

```bash
# Terminal Kali préparation
bash kali/20_preparer_essai.sh TP3
# Terminal Kali proxy
bash kali/30_proxy_transparent.sh TP3
# Terminal Kali capture
bash kali/21_capturer.sh TP3
# Terminal Kali essai, après contrôle du listener KALI:8080
bash kali/22_essai_arp_borne.sh TP3
```

Client : utiliser `02_Requetes_Web.ps1 -Mode http` ou `02_requetes_web.sh http`. L’URL reste celle de WEB, avec query string fictive ; aucun proxy explicite configuré.

Le filtre Kali couvre les connexions client→WEB et Kali→WEB du proxy. Le fichier `.mitm` contient les messages reconstitués. La chaîne NAT redirige seulement TCP 80 du client vers WEB ; les règles ne visent pas tout le LAN. Les compteurs NAT concernent surtout les premiers paquets des connexions.

Pour enregistrer aussi le journal texte, remplacer le lancement interactif par :

```bash
bash kali/30_proxy_transparent.sh TP3 journal
```

Ne pas lancer les deux modes ensemble. Le mode journal utilise mitmdump, le même moteur que mitmproxy ; les flux restent ouvrables dans mitmproxy. Les captures et proxies sont bornés à 240 secondes ; ARP à 180. Arrêter les trois outils, conserver les preuves, puis restaurer (§9).

## 7. TP4 — 16 h à 16 h 45

Avant toute interception, vérifier HTTPS direct avec `-Mode https-direct` (Windows) ou `https-direct` (Debian), et capturer cet accès côté client avec le script 04 TP4. Puis créer une nouvelle référence :

```bash
bash kali/20_preparer_essai.sh TP4
# Terminal proxy ; mode journal conseillé pour documenter la validation amont
bash kali/30_proxy_transparent.sh TP4 journal
# Autre terminal : exporter uniquement la CA publique après démarrage
bash kali/31_exporter_ca_publique.sh
# Terminaux capture et essai
bash kali/21_capturer.sh TP4
bash kali/22_essai_arp_borne.sh TP4
```

Copier seulement `~/lab-mitm/public/mitmproxy-ca-cert.pem` de Kali vers `lab-mitm/mitmproxy-ca-cert.pem` du client via le dossier partagé préparé. Comparer au SHA-256 affiché **sur la console Kali**. Ne copier ni `serveur.key`, ni `mitmproxy-ca.pem`, ni `.p12`.

Windows, pendant l’essai :

```powershell
.\client_windows\02_Requetes_Web.ps1 -Mode https-refus
.\client_windows\02_Requetes_Web.ps1 -Mode https-proxy -SHA256 SHA256_CA_LU_SUR_CONSOLE_KALI
```

Debian :

```bash
bash client_debian/02_requetes_web.sh https-refus
bash client_debian/02_requetes_web.sh https-proxy SHA256_CA_LU_SUR_CONSOLE_KALI
```

Le refus attendu est le code curl 60 accompagné de son message exact. Un autre code, notamment timeout 28 ou connexion 7, bloque la conclusion. Selon le moteur TLS installé, adapter l’interprétation au message documenté ; ne pas masquer l’échec. La confiance proxy s’applique à un appel `--cacert`, sans installer de racine système ni `--insecure`. Les PCAP ordinaires restent chiffrés ; utiliser le `.mitm` pour le contenu reconstitué.

### Contrôle amont négatif — formateur avant la séance

Après restauration, un essai TP4 distinct permet de vérifier que le proxy refuse effectivement le vrai serveur avec une autre CA amont :

```bash
bash kali/20_preparer_essai.sh TP4-neg
bash kali/30_proxy_transparent.sh TP4-neg amont-negatif
# Autres terminaux, même séquence de capture et ARP
bash kali/21_capturer.sh TP4-neg
bash kali/22_essai_arp_borne.sh TP4-neg
```

Sur le client, faire l’appel `https-proxy` avec la **CA publique du proxy** toujours vérifiée. Cet appel est censé échouer parce que le proxy refuse l’amont : le script client renvoie donc une erreur et conserve le corps/code/message. Le journal Kali doit montrer une erreur de validation du certificat amont ; **un 502 seul ne suffit pas**. `ssl_insecure=false` et les options effectives sont conservés dans la référence. Le script négatif génère une autre CA et détruit immédiatement sa clé privée.

Restaurer `TP4-neg`, puis refaire un essai `TP4-ok` en mode `journal` (sans `amont-negatif`) et confirmer le succès. Les deux essais restent bornés, avec deux sauvegardes distinctes. Si l’installation possède d’autres ancres personnalisées faisant accepter le serveur malgré la CA négative, consigner le contrôle non concluant et corriger la configuration de confiance avant la séance.

## 8. TP5 — 16 h 45 à 17 h 15

État sain, côté client, installer l’association réelle FreeSCO :

```powershell
.\client_windows\03_Cache_ARP.ps1 -Action proteger
```

Ou :

```bash
bash client_debian/03_cache_arp.sh proteger
```

Kali sans proxy ni REDIRECT :

```bash
bash kali/20_preparer_essai.sh TP5
bash kali/21_capturer.sh TP5
bash kali/22_essai_arp_borne.sh TP5
```

L’essai TP5 dure **60 secondes**. Observer l’état permanent côté client, refaire HTTP, conserver la capture client TP5. Le cache client doit conserver la MAC FreeSCO. Avec `-r`, le retour FreeSCO→client peut encore être détourné : cette protection n’est pas réciproque.

Option formateur FreeSCO, si `arp -s` existe, après arrêt de la source et vérification de la MAC client :

```sh
sh controle_et_cache.sh proteger IP_CLIENT_REELLE MAC_CLIENT_REELLE
```

Pour un second retest, restaurer Kali puis utiliser `TP5-reciproque` comme nouvel essai. Le script FreeSCO affiche le cache et refuse une entrée permanente net-tools détectée ; le formateur contrôle la sortie réelle si la version diffère. Ne pas supprimer une association administrée préexistante. Si FreeSCO manque de stockage/script compatible, recopier les commandes du script à sa console et relever les résultats.

## 9. Restaurer après CHAQUE essai

1. Arrêter ARP, proxy et captures par Ctrl+C dans leurs terminaux. Les délais automatiques ne remplacent pas le contrôle d’arrêt. Aucun `killall` : ne pas arrêter d’autres travaux.
2. Kali : `bash kali/90_restaurer_essai.sh TP2` (ou l’identifiant **exact** de l’essai courant). Le script refuse les outils encore actifs et retire seulement ses propres règles. Il restaure ip_forward d’abord, puis les neuf valeurs rp_filter/accept_redirects/send_redirects de all/default/IFACE.
3. Client : `03_Cache_ARP.ps1 -Action restaurer` ou `03_cache_arp.sh restaurer`. Retirer uniquement l’entrée passerelle de l’essai, provoquer HTTP et comparer la nouvelle MAC à FreeSCO.
4. FreeSCO : `sh controle_et_cache.sh restaurer IP_CLIENT_REELLE`, puis nouvel accès HTTP côté client, puis `observer`. Relever le retour de la MAC réelle client. Une entrée déjà absente peut produire un message à consigner ; vérifier la résolution plutôt que prétendre une suppression réussie.
5. Client : refaire HTTPS direct avec serveur.crt, hors interception. Vérifier le marqueur et les caches des deux côtés.
6. Kali : `bash kali/91_bilan_final.sh`. Compléter la fiche de contrôle avec les résultats effectivement obtenus.

La comparaison des dix valeurs est automatique. Le relevé sysctl complet et ses écarts restent dans le dossier de preuves : des compteurs changent normalement, mais un paramètre de configuration IPv4 différent exige une analyse et, si nécessaire, la restauration de l’instantané. **La restauration ciblée ne prouve pas un retour intégral.** Le pare-feu iptables est comparé sans ses en-têtes de date ; nft est relevé et comparé séparément, avec des compteurs pouvant différer.

### Exceptions de pare-feu facultatives

Les scripts standards n’ajoutent aucune autorisation filter. Si les politiques Kali bloquent le laboratoire, le formateur peut, **après préparation de l’essai et avant démarrage des outils**, exécuter :

```bash
bash kali/23_regles_flux_optionnelles.sh TP3 ajouter
```

Ce script insère des règles limitées aux adresses/interface/ports pédagogiques : FORWARD client↔WEB, INPUT/OUTPUT du proxy local et de ses connexions amont. Le tag inclut l’identifiant de l’essai. `90_restaurer_essai.sh` les retire automatiquement par leurs arguments exacts. Retrait manuel : même commande avec `retirer`. Il ne modifie ni politique globale ni chaîne nft native. UFW, nftables ou d’autres hooks peuvent encore bloquer : documenter et corriger les règles réelles avec le formateur. Une exception créée manuellement hors de ce script doit être retirée par son exacte commande `-D` avant la comparaison finale.

## 10. Preuves et fin de séance

Chaque `preuves/TPx[-suffixe]/` contient la référence paramètres, sysctl, pare-feu, les PCAP, flux `.mitm`, options et journaux disponibles. Les scripts clients conservent le corps, stderr et le code de chaque requête. Les références ne sont jamais écrasées. Les empreintes/SAN/dates et les captures client restent dans `preuves/` local.

Conserver les preuves et le mini-rapport ; ne pas inclure les clés privées ou le répertoire CA complet dans un dépôt/ZIP apprenant. Le défi et le quiz du support restent des activités de restitution, sans automatisation.

Après validation des preuves le 6 octobre, arrêter les deux services serveur, puis :

```bash
# Sur le serveur
bash 99_supprimer_cles_temporaires.sh serveur
# Sur Kali, après restauration de tout essai
bash 99_supprimer_cles_temporaires.sh kali
```

Cette suppression concerne les fichiers standards de clés actives. Elle n’efface pas les copies déjà faites ou les instantanés. Pour recréer une CA proxy, archiver les certificats publics avec les preuves puis repartir d’un confdir neuf : mélanger des certificats publics anciens avec une nouvelle clé empêcherait les tests de confiance.

## 11. Références techniques

- https://docs.mitmproxy.org/stable/howto/transparent/ — redirection Linux et mode transparent.
- https://docs.mitmproxy.org/stable/concepts/options/ — `ssl_insecure`, CA amont, listener et confdir.
- https://docs.kernel.org/networking/ip-sysctl.html — effets du changement de `ip_forward`.
- https://docs.openssl.org/3.6/man1/openssl-s_server/ — service temporaire `s_server -WWW`.

Ces références justifient les contrôles ; elles ne certifient pas l’exécution sur vos VM.

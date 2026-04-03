# scripts

![PowerShell](https://img.shields.io/badge/PowerShell-Scripts-5391FE?logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Scripts-121011?logo=gnubash&logoColor=white)
![Batch](https://img.shields.io/badge/Batch-Windows-grey)
![PHP](https://img.shields.io/badge/PHP-Web-777BB4?logo=php&logoColor=white)
![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)
![Repo status](https://img.shields.io/badge/Status-Reorganisation-orange)
![Maintenance](https://img.shields.io/badge/Maintained-Yes-success)
![Docs](https://img.shields.io/badge/Documentation-In_progress-blueviolet)
![License](https://img.shields.io/badge/Usage-Internal%20%7C%20Lab-lightgrey)

> Dépôt en cours de réorganisation pour améliorer la lisibilité, le classement par usage et la maintenabilité des scripts.

Dépôt de scripts d’administration, d’automatisation et de support technique pour environnements **Windows**, **Linux** et **Web**.

L’objectif de ce dépôt est simple : **classer proprement les scripts par famille technique**, améliorer la lisibilité, faciliter la maintenance et rendre la réutilisation plus rapide dans un contexte professionnel, pédagogique ou de lab.

---

## Sommaire

- [Vue d’ensemble](#vue-densemble)
- [Arborescence](#arborescence)
- [Pré-requis](#pré-requis)
- [Utilisation rapide](#utilisation-rapide)
- [Description des dossiers](#description-des-dossiers)
- [Conventions du dépôt](#conventions-du-dépôt)
- [Contribution](#contribution)
- [Roadmap](#roadmap)
- [Bonnes pratiques](#bonnes-pratiques)
- [Auteur](#auteur)

---

## Vue d’ensemble

Ce dépôt contient principalement :

- des scripts **Windows** pour l’administration Active Directory, les postes clients et les serveurs ;
- des scripts **Linux** pour l’installation, la configuration et le diagnostic système ;
- des scripts **Web** pour des besoins applicatifs simples ;
- une zone **archive** pour les anciens fichiers à retravailler ;
- une zone **docs** pour documenter la structure et les conventions du dépôt.

Le but n’est pas d’empiler des fichiers à la racine, mais de maintenir un dépôt :

- lisible ;
- structuré ;
- documenté ;
- facile à faire évoluer.

---

## Arborescence

```text
scripts/
├── README.md
├── docs/
│   ├── README.md
│   ├── structure.md
│   └── conventions.md
├── windows/
│   ├── README.md
│   ├── active-directory/
│   ├── workstation/
│   └── server/
├── linux/
│   ├── README.md
│   └── system/
├── web/
│   └── README.md
├── archive/
│   ├── README.md
│   └── legacy-zips/
└── .github/
```

---

## Pré-requis

Avant d’utiliser les scripts de ce dépôt, il faut vérifier :

### Général
- disposer des droits suffisants sur la machine cible ;
- lire le script avant exécution ;
- tester d’abord dans un environnement de lab, de recette ou de VM ;
- vérifier que le script correspond bien à l’OS et au contexte visé.

### Pour Windows
- PowerShell disponible ;
- exécution autorisée si nécessaire ;
- console ouverte avec les droits adaptés ;
- dépendances éventuelles déjà installées.

### Pour Linux
- shell compatible ;
- droits d’exécution ;
- dépendances système présentes ;
- exécution en utilisateur standard ou en root selon le cas.

### Pour Web / PHP
- interpréteur PHP si exécution en CLI ;
- serveur web ou environnement local si test applicatif ;
- paramètres de configuration adaptés.

---

## Utilisation rapide

### Cloner le dépôt

```bash
git clone https://github.com/sbeteta42/scripts.git
cd scripts
```

### Aller dans le bon dossier

Exemples :

```bash
cd windows
```

ou

```bash
cd linux
```

ou

```bash
cd web
```

### Lire le script avant exécution

Exemples :

#### PowerShell
```powershell
Get-Content .\nom-du-script.ps1
```

#### Bash
```bash
cat nom-du-script.sh
```

#### PHP
```bash
cat nom-du-script.php
```

### Exécuter selon le type de script

#### PowerShell
```powershell
.\nom-du-script.ps1
```

#### Batch
```cmd
nom-du-script.bat
```

#### Bash
```bash
chmod +x nom-du-script.sh
./nom-du-script.sh
```

#### PHP
```bash
php nom-du-script.php
```

---

## Description des dossiers

### `windows/`
Scripts liés à l’administration des environnements Microsoft Windows.

Sous-dossiers :
- `active-directory/`
- `workstation/`
- `server/`

### `linux/`
Scripts liés à l’installation, à la configuration et au diagnostic système Linux.

Sous-dossier principal :
- `system/`

### `web/`
Scripts ou fichiers destinés à des usages web simples.

Exemples :
- PHP ;
- petits outils applicatifs ;
- scripts de support.

### `archive/legacy-zips/`
Zone d’archivage temporaire pour :
- anciens ZIP ;
- lots non encore reclassés ;
- contenus à décompresser, trier, renommer ou refactorer.

### `docs/`
Documentation interne du dépôt :
- structure cible ;
- conventions de nommage ;
- bonnes pratiques ;
- règles de maintenance.

---

## Conventions du dépôt

### Classement
Chaque script doit être rangé selon :
- son environnement cible ;
- sa fonction principale.

Exemples :
- script Active Directory → `windows/active-directory/`
- script poste client Windows → `windows/workstation/`
- script serveur Windows → `windows/server/`
- script Linux → `linux/system/`

### Nommage
Les noms de fichiers doivent être :
- explicites ;
- homogènes ;
- sans espaces si possible ;
- en minuscules de préférence ;
- séparés par des tirets.

Exemples :
- `set-ad-password.ps1`
- `join-domain.ps1`
- `install-software-winget.bat`
- `install-vmware-workstation.sh`

### Documentation minimale
Chaque script devrait comporter au minimum :
- un objectif ;
- les prérequis ;
- le contexte d’usage ;
- un exemple d’exécution ;
- les précautions éventuelles.

---

## Contribution

Les contributions doivent rester propres, lisibles et cohérentes avec l’objectif du dépôt.

### Règles de base
- un script = une fonction principale clairement identifiable ;
- pas de fichier jeté à la racine sans raison ;
- pas de nom ambigu ;
- pas d’informations sensibles dans le dépôt ;
- pas de secret, clé, mot de passe ou donnée privée ;
- documentation minimale obligatoire pour tout script important.

### Avant de proposer une modification
- vérifier dans quel dossier le script doit être rangé ;
- renommer correctement le fichier si nécessaire ;
- tester le script dans un environnement maîtrisé ;
- ajouter ou mettre à jour la documentation associée.

### Bon message de commit
Exemples :
- `add powershell script for ad password reset`
- `move workstation scripts into windows/workstation`
- `rename linux install scripts for consistency`
- `add readme for web folder`

---

## Roadmap

### Réorganisation du dépôt
- [x] définir une arborescence claire
- [x] ajouter un README racine
- [ ] ajouter un README par dossier principal
- [ ] déplacer les scripts dans les bons sous-dossiers
- [ ] sortir les anciens ZIP de la racine

### Qualité et maintenance
- [ ] homogénéiser les noms de fichiers
- [ ] documenter les scripts principaux
- [ ] réduire les doublons
- [ ] supprimer les éléments obsolètes
- [ ] standardiser les conventions de nommage

### Documentation
- [ ] compléter `docs/structure.md`
- [ ] compléter `docs/conventions.md`
- [ ] ajouter des exemples d’usage
- [ ] documenter les prérequis par famille de scripts

---

## Bonnes pratiques

- tester en VM ou en lab avant usage réel ;
- relire le code avant exécution ;
- ajouter des commentaires dans les scripts sensibles ;
- éviter les scripts trop longs sans structure ;
- garder une logique simple : un dossier clair, un script identifiable, une fonction comprise ;
- archiver ce qui est ancien au lieu de tout laisser à plat.

---

## Auteur

Dépôt maintenu par **sbeteta42**.

---

## Remarque

Ce dépôt a vocation à devenir une base de scripts propre, exploitable rapidement et simple à maintenir dans le temps.

L’organisation par type de scripts permet :
- de retrouver plus vite un fichier ;
- de documenter plus facilement les usages ;
- d’éviter l’effet dépôt fourre-tout ;
- de rendre le projet plus sérieux dès la page d’accueil GitHub.

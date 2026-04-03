# Structure du dépôt

Ce document décrit l’organisation cible du dépôt `scripts`.

Il sert de référence pour :
- classer les fichiers ;
- savoir où ajouter un nouveau script ;
- maintenir une structure stable et lisible.

---

## 1. Objectif de la structure

La structure du dépôt a été pensée pour éviter :

- les scripts en vrac à la racine ;
- les noms de dossiers flous ;
- les mélanges entre plusieurs types de besoins ;
- la difficulté à retrouver rapidement un script.

L’organisation cible repose sur une logique simple :

- **un type d’environnement**
- **un usage**
- **un emplacement clair**

---

## 2. Vue globale

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

## 3. Description détaillée

### Racine du dépôt

La racine doit rester simple.

Elle contient uniquement :
- le `README.md` principal ;
- les dossiers de premier niveau ;
- les fichiers de structure globale.

### La racine ne doit pas devenir
- un dossier de stockage temporaire ;
- une zone de dépôt brute ;
- un fourre-tout de scripts non classés.

---

## 4. Dossier `docs/`

Le dossier `docs/` contient la documentation interne du dépôt.

### Contenu attendu
- conventions de nommage ;
- structure cible ;
- règles de contribution ;
- notes d’organisation ;
- éventuellement une roadmap ou une documentation de maintenance.

### Exemples
- `docs/README.md`
- `docs/structure.md`
- `docs/conventions.md`

---

## 5. Dossier `windows/`

Le dossier `windows/` contient les scripts destinés aux environnements Microsoft Windows.

### Structure cible

```text
windows/
├── README.md
├── active-directory/
├── workstation/
└── server/
```

### Rôle
Ce dossier permet de séparer clairement :

- les scripts AD ;
- les scripts poste client ;
- les scripts serveur.

---

## 6. Dossier `windows/active-directory/`

Ce sous-dossier contient les scripts liés à :

- la gestion des comptes ;
- la réinitialisation de mots de passe ;
- la jointure au domaine ;
- l’administration Active Directory ;
- certaines tâches liées à DNS/AD si elles relèvent clairement de cet usage.

### Exemples attendus
- `set-ad-password.ps1`
- `modify-ad-user.ps1`
- `join-domain.ps1`

---

## 7. Dossier `windows/workstation/`

Ce sous-dossier contient les scripts pour :

- la préparation de postes clients ;
- l’installation logicielle ;
- la configuration de postes ;
- l’optimisation ou l’automatisation de tâches locales.

### Exemples attendus
- `install-software-winget.bat`
- `optimize-windows.ps1`

---

## 8. Dossier `windows/server/`

Ce sous-dossier contient les scripts destinés aux serveurs Windows :

- installation ;
- préparation ;
- automatisation de configuration ;
- support à l’administration serveur.

### Exemples attendus
- scripts d’installation serveur ;
- scripts d’automatisation d’administration Windows Server ;
- scripts de préparation d’un rôle serveur.

---

## 9. Dossier `linux/`

Le dossier `linux/` contient les scripts destinés aux systèmes Linux.

### Structure cible

```text
linux/
├── README.md
└── system/
```

---

## 10. Dossier `linux/system/`

Ce sous-dossier contient les scripts liés à :

- l’installation ;
- la configuration système ;
- le diagnostic ;
- les vérifications techniques ;
- l’automatisation Bash ou shell.

### Exemples attendus
- scripts d’installation de paquets ;
- scripts de vérification réseau ;
- scripts de contrôle de services ;
- scripts d’automatisation système.

---

## 11. Dossier `web/`

Le dossier `web/` contient les scripts ou fichiers liés à des usages web simples.

### Exemples de contenu
- PHP ;
- utilitaires web ;
- petits traitements applicatifs ;
- scripts techniques de support.

### Ce dossier ne doit pas devenir
- un dépôt d’application complète mal structurée ;
- une zone de stockage fourre-tout pour fichiers non classés.

---

## 12. Dossier `archive/`

Le dossier `archive/` sert à stocker temporairement l’existant qui n’a pas encore été retraité proprement.

### Structure cible

```text
archive/
├── README.md
└── legacy-zips/
```

### Rôle
Il permet de :
- sortir les anciens ZIP de la racine ;
- garder une trace de l’existant ;
- préparer un reclassement progressif.

### Important
`archive/` n’est pas la destination finale des scripts utiles.  
C’est une zone tampon.

---

## 13. Dossier `.github/`

Le dossier `.github/` peut contenir :
- templates d’issues ;
- templates de pull requests ;
- fichiers de configuration GitHub ;
- éventuellement workflows si le dépôt évolue.

Ce dossier sert à professionnaliser la maintenance du dépôt.

---

## 14. Règles d’évolution de la structure

La structure doit rester stable.

### On ajoute un nouveau dossier uniquement si :
- il répond à un vrai besoin ;
- il regroupe une famille cohérente de scripts ;
- il évite une confusion durable.

### On n’ajoute pas un nouveau dossier pour :
- un seul fichier isolé sans logique durable ;
- contourner un problème de classement ;
- créer un sous-dossier temporaire qui finira oublié.

---

## 15. Méthode de classement d’un nouveau script

Avant d’ajouter un fichier, appliquer cette logique :

### Étape 1
Identifier la plateforme cible :
- Windows
- Linux
- Web

### Étape 2
Identifier sa fonction :
- AD
- poste client
- serveur
- système
- utilitaire web

### Étape 3
Placer le fichier dans le dossier correspondant.

### Étape 4
Vérifier :
- le nom du fichier ;
- la cohérence avec les autres scripts ;
- la nécessité de documenter le script.

---

## 16. Exemple de classement

### Cas 1
Script PowerShell de réinitialisation de mot de passe AD  
→ `windows/active-directory/`

### Cas 2
Script Batch d’installation de logiciels sur poste utilisateur  
→ `windows/workstation/`

### Cas 3
Script Bash de vérification de service Linux  
→ `linux/system/`

### Cas 4
Script PHP simple de changement de mot de passe en environnement web  
→ `web/`

### Cas 5
Ancienne archive ZIP contenant des scripts non triés  
→ `archive/legacy-zips/`

---

## 17. Structure cible à moyen terme

À terme, le dépôt doit tendre vers :

- moins de ZIP ;
- moins de doublons ;
- des noms homogènes ;
- un README par dossier important ;
- une documentation minimale partout où c’est nécessaire.

---

## 18. Résumé

La structure du dépôt repose sur une idée simple :

- **Windows**
- **Linux**
- **Web**
- **Archive**
- **Docs**

Chaque grand dossier a un rôle clair.  
Chaque script doit pouvoir être rangé sans ambiguïté.

Si un fichier ne trouve pas naturellement sa place, c’est qu’il faut :
- revoir son nom ;
- revoir son rôle ;
- ou revoir la structure du dépôt.

# Windows Scripts

![PowerShell](https://img.shields.io/badge/PowerShell-Windows-blue?logo=powershell)
![Batch](https://img.shields.io/badge/Batch-Scripts-grey)
![Windows](https://img.shields.io/badge/Platform-Windows-0078D6?logo=windows)

Scripts dédiés aux environnements **Windows**.

Ce dossier regroupe les scripts liés à :
- l’administration **Active Directory** ;
- la préparation de **postes clients** ;
- la configuration de **serveurs Windows**.

---

## Sommaire

- [Structure](#structure)
- [Utilisation rapide](#utilisation-rapide)
- [Sous-dossiers](#sous-dossiers)
- [Bonnes pratiques](#bonnes-pratiques)

---

## Structure

```text
windows/
├── active-directory/
├── workstation/
├── server/
└── README.md
```

---

## Utilisation rapide

### Exécuter un script PowerShell
Exemple :

```powershell
.\nom-du-script.ps1
```

Ouvrir PowerShell en administrateur si nécessaire.

### Vérifier la politique d’exécution
Exemple :

```powershell
Get-ExecutionPolicy
```

### Exécuter un script batch
Exemple :

```cmd
nom-du-script.bat
```

---

## Sous-dossiers

### `active-directory/`
Scripts pour :
- gestion des comptes ;
- réinitialisation de mots de passe ;
- jointure au domaine ;
- configuration liée à AD/DNS.

### `workstation/`
Scripts pour :
- installation de logiciels ;
- configuration initiale de postes ;
- optimisation et automatisation de tâches usuelles.

### `server/`
Scripts pour :
- préparation de serveurs ;
- automatisation d’installations ;
- support à l’administration Windows Server.

---

## Bonnes pratiques

- vérifier les droits nécessaires avant exécution ;
- tester en lab avant usage en environnement réel ;
- lire le script avant lancement ;
- documenter tout changement important ;
- ne pas mélanger scripts serveur, poste client et AD dans un même dossier.

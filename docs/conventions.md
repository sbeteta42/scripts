# Conventions du dépôt

Ce document définit les règles de classement, de nommage, de documentation et de maintenance du dépôt.

L’objectif est simple : garder un dépôt **lisible**, **cohérent** et **facile à maintenir**.

---

## 1. Principes généraux

Le dépôt doit rester :

- structuré ;
- compréhensible rapidement ;
- maintenable dans le temps ;
- exploitable sans devoir ouvrir 50 scripts pour comprendre leur rôle.

Chaque script doit avoir :
- une place logique ;
- un nom clair ;
- une fonction identifiable ;
- un minimum de contexte.

---

## 2. Règles de classement

Les scripts doivent être classés selon :

1. **l’environnement cible**
2. **la fonction principale**
3. **le type d’usage**

### Exemples

- script Active Directory → `windows/active-directory/`
- script poste client Windows → `windows/workstation/`
- script serveur Windows → `windows/server/`
- script Linux système → `linux/system/`
- script PHP ou utilitaire web → `web/`

### Ce qu’il faut éviter

- mettre des scripts différents à la racine ;
- mélanger scripts serveur, poste client et AD dans un même dossier ;
- créer des dossiers ambigus du type `divers`, `test`, `temp`, `old2`, `new-final`.

---

## 3. Convention de nommage des fichiers

Les noms de fichiers doivent être :

- explicites ;
- homogènes ;
- faciles à lire ;
- sans espaces si possible ;
- cohérents avec leur usage.

### Format recommandé

Utiliser de préférence :

- des minuscules ;
- des tirets `-` comme séparateurs ;
- des noms orientés action ou fonction.

### Exemples recommandés

- `set-ad-password.ps1`
- `join-domain.ps1`
- `install-software-winget.bat`
- `install-vmware-workstation.sh`
- `check-dhcp.sh`

### Ce qu’il faut éviter

- `script1.ps1`
- `test_final_v2.ps1`
- `nouveau script.bat`
- `oklinux.sh`
- `truc.php`

---

## 4. Convention de nommage des dossiers

Les dossiers doivent avoir des noms :

- courts ;
- clairs ;
- techniques ;
- stables dans le temps.

### Exemples valides

- `windows`
- `active-directory`
- `workstation`
- `server`
- `linux`
- `system`
- `web`
- `archive`
- `docs`

### Ce qu’il faut éviter

- `mes_scripts`
- `bazar`
- `a_trier`
- `utile`
- `autres`

---

## 5. Documentation minimale par script

Chaque script important devrait contenir ou être accompagné de :

- un objectif ;
- les prérequis ;
- le système cible ;
- les droits nécessaires ;
- un exemple d’exécution ;
- les points d’attention éventuels.

### Exemple minimal attendu en en-tête

#### PowerShell
```powershell
# Objectif : Réinitialiser le mot de passe d’un utilisateur AD
# Cible    : Windows Server / Active Directory
# Prérequis: Module ActiveDirectory
# Usage    : .\set-ad-password.ps1
```

#### Bash
```bash
#!/bin/bash
# Objectif : Vérifier un service réseau
# Cible    : Linux
# Usage    : ./check-service.sh
```

---

## 6. Langue et style

Le dépôt peut contenir des scripts en français ou en anglais, mais il faut garder une logique cohérente.

### Recommandation
- noms de fichiers : anglais technique simple ou convention unique ;
- commentaires : français ou anglais, mais de manière cohérente dans le même script ;
- README : français clair si le dépôt est destiné à un usage personnel, pro ou pédagogique francophone.

### À éviter
- mélanger plusieurs styles dans un même fichier ;
- utiliser des noms flous ;
- écrire des commentaires inutiles ou trompeurs.

---

## 7. Structure d’un script

Un script propre doit idéalement suivre cette logique :

1. en-tête de description
2. variables / paramètres
3. vérifications préalables
4. traitement principal
5. affichage des résultats ou statut
6. gestion d’erreur minimale

---

## 8. Gestion des archives

Les archives ZIP ou anciens lots de scripts ne doivent pas rester à la racine.

Ils doivent être placés dans :

```text
archive/legacy-zips/
```

Cette zone sert à :

- stocker temporairement l’existant ;
- éviter le désordre à la racine ;
- préparer le tri, le renommage ou la refactorisation.

### Règle
Tout fichier placé dans `archive/` a vocation à être :

- déplacé ;
- décompressé ;
- renommé ;
- intégré proprement ;
- ou supprimé s’il n’a plus d’intérêt.

---

## 9. Gestion des doublons

Les doublons doivent être évités autant que possible.

Si plusieurs scripts font presque la même chose :

- garder la version la plus propre ;
- renommer clairement ;
- fusionner si pertinent ;
- archiver ou supprimer les variantes obsolètes.

### À éviter
- plusieurs scripts identiques avec des noms différents ;
- plusieurs versions non documentées ;
- des variantes sans indication claire sur leur rôle.

---

## 10. Sécurité et hygiène du dépôt

Le dépôt ne doit pas contenir :

- de mots de passe en clair ;
- de clés API ;
- de secrets ;
- de fichiers d’export sensibles ;
- de données personnelles non nécessaires.

### Bonnes pratiques
- relire les scripts avant commit ;
- retirer les données sensibles ;
- documenter les dépendances ;
- garder le dépôt publiable proprement.

---

## 11. Règles de contribution

Avant d’ajouter ou modifier un script :

- vérifier le bon dossier cible ;
- appliquer les conventions de nommage ;
- tester le script ;
- commenter le minimum utile ;
- mettre à jour le README si nécessaire.

### Messages de commit recommandés

- `add powershell script for ad password reset`
- `move workstation scripts into windows/workstation`
- `rename linux scripts for consistency`
- `add documentation for web folder`

---

## 12. Règle simple à retenir

Un bon ajout dans ce dépôt doit répondre à 4 questions :

- **où va ce script ?**
- **à quoi sert-il ?**
- **comment se lance-t-il ?**
- **est-ce qu’un autre script fait déjà la même chose ?**

Si une de ces réponses n’est pas claire, le script n’est pas prêt à être ajouté proprement.

---

## 13. Résumé

Les conventions du dépôt reposent sur 5 idées simples :

- classer par type d’environnement ;
- nommer clairement ;
- documenter le minimum utile ;
- éviter le vrac et les doublons ;
- garder un dépôt propre et maintenable.

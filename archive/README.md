# Archive

Ce dossier contient les anciens fichiers, archives ou lots de scripts qui n’ont pas encore été reclassés proprement dans l’arborescence principale du dépôt.

Il s’agit d’une zone tampon destinée à garder un historique exploitable sans encombrer la racine du dépôt.

---

## Rôle du dossier `archive/`

Le dossier `archive/` sert à stocker temporairement :

- d’anciens fichiers compressés ;
- des lots de scripts non triés ;
- des contenus à décompresser ;
- des éléments à renommer, refactoriser ou reclasser.

Son but est simple :
- sortir le vrac de la racine ;
- conserver une trace de l’existant ;
- préparer un reclassement progressif.

---

## Structure recommandée

```text
archive/
├── README.md
└── legacy-zips/
```

### `legacy-zips/`
Sous-dossier destiné aux anciennes archives compressées qui n’ont pas encore été retraitées.

---

## Important

Le dossier `archive/` n’est **pas** la structure cible du dépôt.

C’est une zone temporaire.  
Tout élément présent ici devrait, à terme, être :

- déplacé dans le bon dossier ;
- décompressé puis trié ;
- renommé correctement ;
- intégré proprement ;
- ou supprimé s’il n’a plus d’utilité.

---

## Ce qu’il faut mettre ici

Exemples :
- anciens ZIP de scripts ;
- exports historiques ;
- paquets non encore analysés ;
- variantes en attente de tri.

---

## Ce qu’il faut éviter

Le dossier `archive/` ne doit pas devenir :
- une poubelle permanente ;
- un second dépôt non maintenu ;
- un emplacement définitif pour des scripts encore utiles.

Si un script est toujours utile et clairement identifiable, il doit être déplacé vers :
- `windows/`
- `linux/`
- `web/`
selon son usage réel.

---

## Bonnes pratiques

- dater ou nommer proprement les archives si nécessaire ;
- éviter les doublons inutiles ;
- retrier régulièrement le contenu ;
- supprimer ce qui est obsolète ;
- ne pas laisser l’archive grossir sans contrôle.

---

## Objectif

Le dossier `archive/` existe pour améliorer la lisibilité globale du dépôt.

Il permet de garder une racine propre tout en conservant l’existant le temps de la réorganisation.

La règle est simple :

- ce qui est **utile et clair** doit être rangé dans la bonne arborescence ;
- ce qui est **ancien ou en attente de tri** peut passer temporairement par `archive/`.

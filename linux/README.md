# Linux Scripts

![Bash](https://img.shields.io/badge/Bash-Linux-black?logo=gnubash)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)

Scripts dédiés aux environnements **Linux**.

Ce dossier regroupe les scripts liés à :
- l’installation ;
- la configuration ;
- l’automatisation ;
- les vérifications et diagnostics système.

---

## Sommaire

- [Structure](#structure)
- [Utilisation rapide](#utilisation-rapide)
- [Sous-dossiers](#sous-dossiers)
- [Bonnes pratiques](#bonnes-pratiques)

---

## Structure

```text
linux/
├── system/
└── README.md
```

---

## Utilisation rapide

### Rendre un script exécutable

```bash
chmod +x nom-du-script.sh
```

### Exécuter un script

```bash
./nom-du-script.sh
```

ou

```bash
bash nom-du-script.sh
```

### Vérifier le contenu avant exécution

```bash
cat nom-du-script.sh
```

ou

```bash
less nom-du-script.sh
```

---

## Sous-dossiers

### `system/`
Scripts pour :
- installation de composants ;
- configuration système ;
- vérifications réseau ;
- diagnostic ;
- automatisation de tâches d’administration Linux.

---

## Bonnes pratiques

- exécuter les scripts avec le bon niveau de privilège ;
- éviter de lancer un script sans l’avoir lu ;
- prévoir un test en machine de lab ou VM ;
- commenter les scripts les plus sensibles ;
- garder une logique simple : un script = une fonction principale.

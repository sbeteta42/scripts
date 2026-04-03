# Automatiser et simplifier la création d’un ou plusieurs comptes utilisateurs Active Directory, en les associant automatiquement à une OU et un groupe, avec vérifications et créations à la volée si besoin.
# Auteur : sbeteta@beteta.org 

# Import du module Active Directory
Import-Module ActiveDirectory  # Importe le module Active Directory pour gérer les objets AD

function Create-ADUserInteractive {  # Déclare une fonction interactive pour créer un utilisateur AD
    Write-Host "`n===== Création d'un utilisateur Active Directory =====" -ForegroundColor Cyan

    # Saisie des données utilisateur
    $prenom = Read-Host "Veuillez saisir le Prénom"  # Demande le prénom de l'utilisateur
    $nom = Read-Host "Veuillez saisir le Nom"  # Demande le nom de l'utilisateur
    $titre = Read-Host "Veuillez saisir le Titre du poste"  # Demande le titre/poste de l'utilisateur
    $departement = Read-Host "Veuillez saisir l Département"  # Demande le département de l'utilisateur
    $login = Read-Host "Entrer le Login (sAMAccountName)"  # Demande le login (sAMAccountName)
    $ou = Read-Host "Entrer le Nom de l'OU (ex : RH)"  # Demande le nom de l'utilisateur
    $groupe = Read-Host "Entrer le Nom du groupe (ex : RH-GRP)"  # Demande le nom de l'utilisateur
    $motDePasse = Read-Host "Entrer le Mot de passe de l'utilisateur" -AsSecureString  # Demande un mot de passe sécurisé pour l'utilisateur

    # Variables dérivées
    $nomComplet = "$prenom $nom"  # Construit le nom complet à partir du prénom et nom
    $upn = "$login@formation.lan"  # Génère l'UPN (UserPrincipalName)
    $ouPath = "OU=$ou,DC=formation,DC=lan"  # Définit le chemin LDAP de l'OU

    # Vérifie si l'OU existe, sinon la créer
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {  # Vérifie si l'OU existe déjà dans l'annuaire
        Write-Host "OU '$ou' introuvable. Création..." -ForegroundColor Yellow
        New-ADOrganizationalUnit -Name $ou -Path "DC=formation,DC=lan"  # Crée l'OU si elle n'existe pas
    }

    # Crée l’utilisateur
    Write-Host "Création de l’utilisateur $nomComplet..."  # Construit le nom complet à partir du prénom et nom
    New-ADUser -Name $nomComplet `  # Construit le nom complet à partir du prénom et nom
        -GivenName $prenom `
        -Surname $nom `
        -SamAccountName $login `
        -UserPrincipalName $upn `  # Génère l'UPN (UserPrincipalName)
        -Path $ouPath `  # Définit le chemin LDAP de l'OU
        -Enabled $true `
        -AccountPassword $motDePasse

    # Mise à jour des attributs
    Set-ADUser -Identity $login -Title $titre -Department $departement  # Met à jour les attributs comme le titre et le département

    # Vérifie si le groupe existe, sinon le créer
    if (-not (Get-ADGroup -Filter "Name -eq '$groupe'" -SearchBase $ouPath -ErrorAction SilentlyContinue)) {  # Définit le chemin LDAP de l'OU
        Write-Host "Groupe '$groupe' introuvable. Création..." -ForegroundColor Yellow
        New-ADGroup -Name $groupe -GroupScope Global -GroupCategory Security -Path $ouPath  # Définit le chemin LDAP de l'OU
    }

    # Ajoute l’utilisateur au groupe
    Add-ADGroupMember -Identity $groupe -Members $login  # Ajoute l'utilisateur au groupe spécifié

    Write-Host "Utilisateur $nomComplet ajouté au groupe $groupe avec succès." -ForegroundColor Green  # Construit le nom complet à partir du prénom et nom
}

# Boucle pour plusieurs créations
do {  # Débute une boucle pour créer plusieurs utilisateurs
    Create-ADUserInteractive
    $reponse = Read-Host "`nSouhaitez-vous créer un autre utilisateur ? (o/n)"
} while ($reponse -eq "o")  # Répète la création si l'utilisateur répond 'o'

Write-Host "`nScript terminé. Tous les utilisateurs ont été traités." -ForegroundColor Cyan  # Affiche un message de fin de script

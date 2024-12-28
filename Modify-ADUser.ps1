param (
    [string]$Username,
    [string]$NewDisplayName,
    [string]$NewEmail
)

# Charger le module Active Directory
Import-Module ActiveDirectory

try {
    # Rechercher l'utilisateur dans AD
    $user = Get-ADUser -Filter {SamAccountName -eq $Username}

    if ($user) {
        # Modifier les propriétés de l'utilisateur
        Set-ADUser -Identity $user.DistinguishedName -DisplayName $NewDisplayName -EmailAddress $NewEmail

        Write-Output "Utilisateur $Username modifié avec succès."
    } else {
        Write-Output "Utilisateur $Username non trouvé."
    }
} catch {
    Write-Output "Erreur : $_"
}


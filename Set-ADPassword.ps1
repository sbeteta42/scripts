# modification d'un mot de passe Active Directory
#par sbeteta@beteta.org
param(
    [string]$username,
    [string]$newPassword
)

# Import du module Active Directory
Import-Module ActiveDirectory

try {
    # Récupération de l'utilisateur
    $user = Get-ADUser -Identity $username

    if ($user -ne $null) {
        # Modification du mot de passe
        Set-ADAccountPassword -Identity $username -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) -Reset
        Write-Output "Mot de passe de l'utilisateur '$username' modifié avec succès."
    } else {
        Write-Output "Utilisateur '$username' introuvable."
    }
} catch {
    Write-Output "Erreur : $($_.Exception.Message)"
}


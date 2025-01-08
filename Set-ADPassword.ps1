# Importer le module Active Directory
Import-Module ActiveDirectory

# Demander le nom d'utilisateur
$username = Read-Host "Entrez le nom d'utilisateur du compte Active Directory"

# Vérifier si l'utilisateur existe dans Active Directory
try {
    $user = Get-ADUser -Identity $username -ErrorAction Stop
    Write-Host "Utilisateur trouvé : $($user.Name)" -ForegroundColor Green
} catch {
    Write-Host "Erreur : L'utilisateur '$username' est introuvable dans Active Directory." -ForegroundColor Red
    exit
}

# Demander le mot de passe actuel
$currentPassword = Read-Host "Entrez le mot de passe actuel" -AsSecureString

# Demander le nouveau mot de passe
$newPassword = Read-Host "Entrez le nouveau mot de passe" -AsSecureString

# Confirmer le nouveau mot de passe
$newPasswordConfirm = Read-Host "Confirmez le nouveau mot de passe" -AsSecureString

# Vérifier que les deux mots de passe correspondent
if (([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))) -ne 
    ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPasswordConfirm)))) {
    Write-Host "Erreur : Les mots de passe ne correspondent pas." -ForegroundColor Red
    exit
}

# Tenter de modifier le mot de passe
try {
    Set-ADAccountPassword -Identity $username `
                          -OldPassword $currentPassword `
                          -NewPassword $newPassword `
                          -Confirm:$false
    Write-Host "Mot de passe pour l'utilisateur '$username' modifié avec succès." -ForegroundColor Green
} catch {
    Write-Host "Erreur lors de la modification du mot de passe : $($_.Exception.Message)" -ForegroundColor Red
}

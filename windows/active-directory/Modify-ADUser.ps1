param (
    [string]$Username,
    [string]$NewPassword
)

# Importer le module Active Directory
Import-Module ActiveDirectory

# Changer le mot de passe
try {
    Set-ADAccountPassword -Identity $Username -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
    Write-Output "Le mot de passe a été changé avec succès pour l'utilisateur $Username."
} catch {
    Write-Output "Erreur : $_"
}

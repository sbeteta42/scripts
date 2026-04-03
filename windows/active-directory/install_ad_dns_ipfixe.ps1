# Script PowerShell pour installer un contrôleur de domaine principal Windows Server 2022

# -------------------------
# 1. CONFIGURATION RESEAU
# -------------------------

# Interface réseau
$InterfaceAlias = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).InterfaceAlias

# Configuration IP statique
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress "192.168.1.101" -PrefixLength 24 -DefaultGateway "192.168.1.1"

# Configuration DNS (localhost pour l’instant)
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses "127.0.0.1"

# -------------------------
# 2. INSTALLATION DES ROLES
# -------------------------

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# -------------------------
# 3. PROMOTION EN CONTROLEUR DE DOMAINE
# -------------------------

# Définir le mot de passe DSRM
$SecurePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

# Promouvoir le serveur comme nouveau DC dans une nouvelle forêt
Install-ADDSForest `
  -DomainName "formation.lan" `
  -DomainNetbiosName "FORMATION" `
  -SafeModeAdministratorPassword $SecurePassword `
  -InstallDNS `
  -Force

# Redémarrage automatique à la fin de la promotion de SRV01


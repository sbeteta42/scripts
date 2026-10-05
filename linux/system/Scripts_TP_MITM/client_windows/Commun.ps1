# Fonctions communes aux scripts Windows PowerShell 5.1 et PowerShell 7.
# Dot-sourcing par les scripts ; aucune exécution globale de politique modifiée.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$LabDir = Join-Path $env:USERPROFILE 'lab-mitm'
function Assert-Admin {
 $p = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
 if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Ouvrir PowerShell en administrateur.' }
}
function Assert-PrivateIPv4([string]$Value) {
 $ip = $null
 if (-not [Net.IPAddress]::TryParse($Value, [ref]$ip) -or $ip.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetwork) { throw "IPv4 invalide : $Value" }
 $b = $ip.GetAddressBytes()
 if (-not ($b[0] -eq 10 -or ($b[0] -eq 172 -and $b[1] -ge 16 -and $b[1] -le 31) -or ($b[0] -eq 192 -and $b[1] -eq 168))) { throw 'IPv4 hors des réseaux privés du TP.' }
}
function Assert-Hash([string]$File, [string]$Expected) {
 if ($Expected -notmatch '^[a-fA-F0-9]{64}$') { throw 'SHA-256 de 64 caractères attendu depuis la console de référence.' }
 $actual = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
 if ($actual -ne $Expected) { throw "Empreinte incorrecte : $File" }
 Write-Host "SHA-256 validé : $actual"
}
function Load-Lab {
 $f = Join-Path $LabDir 'client.json'
 if (-not (Test-Path -LiteralPath $f)) { throw 'Lancer 00_Configuration.ps1.' }
 $script:Lab = Get-Content -LiteralPath $f -Raw | ConvertFrom-Json
 foreach ($v in @($Lab.Client, $Lab.GW, $Lab.Web)) { Assert-PrivateIPv4 $v }
 $adapter = Get-NetAdapter -Name $Lab.Alias
 if (-not (Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 | Where-Object IPAddress -eq $Lab.Client)) { throw 'IP client différente de la configuration ; contrôler DHCP.' }
 $route = Find-NetRoute -RemoteIPAddress $Lab.Web | Where-Object { $_.PSObject.Properties.Name -contains 'NextHop' } | Select-Object -First 1
 if (-not $route -or $route.NextHop -ne $Lab.GW -or $route.InterfaceIndex -ne $adapter.ifIndex) { throw 'La route vers WEB ne passe pas par FreeSCO sur le LAN indiqué.' }
 New-Item -ItemType Directory -Force (Join-Path $LabDir 'preuves') | Out-Null
 Get-Command curl.exe -ErrorAction Stop | Out-Null
}
function Assert-ServerCert {
 $hashFile = Join-Path $LabDir 'serveur.sha256'
 Assert-Hash (Join-Path $LabDir 'serveur.crt') ((Get-Content -LiteralPath $hashFile -Raw).Trim())
}
function Invoke-LabWeb([string]$Label, [string]$Url, [string]$CA = '', [bool]$Refusal = $false) {
 $base = Join-Path $LabDir ('preuves\' + $Label + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
 $argsCurl = @('--noproxy', '*', '--http1.1', '--max-time', '10', '--fail', '--show-error')
 if ($CA) { $argsCurl += @('--cacert', $CA) }
 # En PS7, ne pas transformer automatiquement le code natif attendu du refus TLS en exception.
 if (Test-Path variable:PSNativeCommandUseErrorActionPreference) { $PSNativeCommandUseErrorActionPreference = $false }
 $oldPreference = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
 try {
  & curl.exe @argsCurl $Url 1> ($base + '.corps.txt') 2> ($base + '.erreur.txt')
  $code = $LASTEXITCODE
 } finally { $ErrorActionPreference = $oldPreference }
 $code | Set-Content -LiteralPath ($base + '.code.txt')
 Get-Content -LiteralPath ($base + '.corps.txt')
 Get-Content -LiteralPath ($base + '.erreur.txt') | ForEach-Object { Write-Host $_ }
 if ($Refusal) {
  if ($code -ne 60) { throw "Refus TLS attendu ; code réel $code. Lire le message exact, un timeout ne prouve rien." }
  Write-Host 'Défaut de validation du certificat signalé par curl ; corréler au proxy.'
 } else {
  if ($code -ne 0) { throw "Échec curl : $code. Voir $base.*" }
  if (-not (Select-String -LiteralPath ($base + '.corps.txt') -SimpleMatch 'MESSAGE_FICTIF_MITM_2026' -Quiet)) { throw 'Marqueur pédagogique absent.' }
 }
}

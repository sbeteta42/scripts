<# Avant 13 h : paramètres réels, jamais d’alias Ethernet ni d’IP imposés. #>
. (Join-Path $PSScriptRoot 'Commun.ps1')
Assert-Admin
New-Item -ItemType Directory -Force $LabDir | Out-Null
$f = Join-Path $LabDir 'client.json'
if (Test-Path $f) { throw 'client.json existe : conserver la référence avant reconfiguration.' }
Get-NetAdapter | Format-Table Name, ifIndex, Status, MacAddress
Get-NetIPConfiguration
Get-NetRoute -AddressFamily IPv4
$alias = Read-Host 'Alias LAN réel du client'
$client = Read-Host 'IPv4 réelle du client'
$gw = Read-Host 'IPv4 LAN réelle FreeSCO'
$web = Read-Host 'IPv4 réelle serveur pédagogique'
$mac = (Read-Host 'MAC LAN FreeSCO vérifiée sur console').Replace(':', '-').ToUpperInvariant()
foreach ($v in @($client, $gw, $web)) { Assert-PrivateIPv4 $v }
if ($mac -notmatch '^([A-F0-9]{2}-){5}[A-F0-9]{2}$') { throw 'MAC invalide.' }
Get-NetAdapter -Name $alias | Out-Null
[ordered]@{Alias=$alias; Client=$client; GW=$gw; Web=$web; GatewayMac=$mac} | ConvertTo-Json | Set-Content -LiteralPath $f -Encoding UTF8
Load-Lab
& curl.exe --version
Write-Host 'Paramètres sauvegardés ; conserver le relevé console des MAC et le moteur TLS curl.'

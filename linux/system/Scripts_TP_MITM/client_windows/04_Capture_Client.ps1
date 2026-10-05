<# Usage : .\04_Capture_Client.ps1 -TP TP1|TP4|TP5
   Wireshark/Npcap installés et autorisés avant la séance. Capture PCAPNG bornée à 240 s. #>
param([Parameter(Mandatory=$true)][ValidateSet('TP1','TP4','TP5')][string]$TP)
. (Join-Path $PSScriptRoot 'Commun.ps1')
Load-Lab; Assert-Admin
$dumpcap = Join-Path $env:ProgramFiles 'Wireshark\dumpcap.exe'
if (-not (Test-Path -LiteralPath $dumpcap)) { throw 'Wireshark/dumpcap absent de Program Files ; adapter ce chemin si nécessaire.' }
$adapter = Get-NetAdapter -Name $Lab.Alias
$guid = ([guid]$adapter.InterfaceGuid).ToString('B')
$iface = '\Device\NPF_' + $guid
& $dumpcap -D
$out = Join-Path $LabDir ('preuves\' + $TP + '_client_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff') + '.pcapng')
& $dumpcap -i $iface -a duration:240 -s 0 -f "arp or (host $($Lab.Client) and host $($Lab.Web))" -w $out
if ($LASTEXITCODE -ne 0) { throw 'Capture en échec : vérifier GUID, Npcap et droits.' }
Get-FileHash -LiteralPath $out -Algorithm SHA256 | Format-List | Out-File -LiteralPath ($out + '.sha256.txt')

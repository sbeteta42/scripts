<# Usage : .\03_Cache_ARP.ps1 -Action observer|proteger|restaurer
   TP5 : association temporaire ActiveStore, seulement la passerelle validée. #>
param([Parameter(Mandatory=$true)][ValidateSet('observer','proteger','restaurer')][string]$Action)
. (Join-Path $PSScriptRoot 'Commun.ps1')
Load-Lab; Assert-Admin
$marker = Join-Path $LabDir 'protection_client_active'
$log = Join-Path $LabDir ('preuves\cache_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff') + '.txt')
function Get-LabNeighbor { @(Get-NetNeighbor -InterfaceAlias $Lab.Alias -AddressFamily IPv4 | Where-Object IPAddress -eq $Lab.GW) }
function Show-LabNeighbor { Get-LabNeighbor | Format-List * | Out-String | Tee-Object -FilePath $log -Append }
switch ($Action) {
 'observer' { Show-LabNeighbor }
 'proteger' {
  if (Test-Path $marker) { throw 'Protection du TP déjà active.' }
  $entries = @(Get-LabNeighbor); Show-LabNeighbor
  if ($entries | Where-Object State -eq 'Permanent') { throw 'Association permanente préexistante : consulter le formateur.' }
  if ($entries.Count -gt 0) { Remove-NetNeighbor -InterfaceAlias $Lab.Alias -IPAddress $Lab.GW -Confirm:$false }
  New-Item -ItemType File -Path $marker | Out-Null
  New-NetNeighbor -InterfaceAlias $Lab.Alias -IPAddress $Lab.GW -LinkLayerAddress $Lab.GatewayMac -State Permanent -PolicyStore ActiveStore | Out-Null
  Show-LabNeighbor
  if (-not (Get-LabNeighbor | Where-Object State -eq 'Permanent')) { throw 'État permanent non obtenu.' }
 }
 'restaurer' {
  $entries = @(Get-LabNeighbor)
  if (($entries | Where-Object State -eq 'Permanent') -and -not (Test-Path $marker)) { throw 'Entrée fixe sans témoin du TP : ne pas la supprimer.' }
  if ($entries.Count -gt 0) { Remove-NetNeighbor -InterfaceAlias $Lab.Alias -IPAddress $Lab.GW -PolicyStore ActiveStore -Confirm:$false }
  if (Test-Path $marker) { Remove-Item -LiteralPath $marker }
  Invoke-LabWeb 'ARP_reconstruction' "http://$($Lab.Web)/index.html"
  Show-LabNeighbor
  $entry = Get-LabNeighbor | Select-Object -First 1
  if (-not $entry -or $entry.LinkLayerAddress.Replace(':','-') -ne $Lab.GatewayMac) { throw 'MAC passerelle différente de la console FreeSCO.' }
 }
}

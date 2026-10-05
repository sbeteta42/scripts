<# Usage : .\02_Requetes_Web.ps1 -Mode http|https-direct|https-refus|https-proxy [-SHA256 ...]
   --cacert s’applique à un seul appel, aucun magasin de confiance modifié. #>
param([Parameter(Mandatory=$true)][ValidateSet('http','https-direct','https-refus','https-proxy')][string]$Mode, [string]$SHA256='')
. (Join-Path $PSScriptRoot 'Commun.ps1')
Load-Lab
switch ($Mode) {
 'http' { Invoke-LabWeb 'HTTP' "http://$($Lab.Web)/index.html?module=MITM&message=EXERCICE" }
 'https-direct' { Assert-ServerCert; Invoke-LabWeb 'HTTPS_direct' "https://$($Lab.Web)/index.html" (Join-Path $LabDir 'serveur.crt') }
 'https-refus' { Assert-ServerCert; Invoke-LabWeb 'HTTPS_refus' "https://$($Lab.Web)/index.html" (Join-Path $LabDir 'serveur.crt') $true }
 'https-proxy' {
  $ca = Join-Path $LabDir 'mitmproxy-ca-cert.pem'
  Assert-Hash $ca $SHA256
  if (Select-String -LiteralPath $ca -SimpleMatch 'PRIVATE KEY' -Quiet) { throw 'CA contenant une clé privée interdite.' }
  Invoke-LabWeb 'HTTPS_proxy' "https://$($Lab.Web)/index.html" $ca
 }
}

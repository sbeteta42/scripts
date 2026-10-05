<# Usage : .\01_Certificat_Direct.ps1 -SHA256 SHA256_CONSOLE_FORMATEUR #>
param([Parameter(Mandatory=$true)][string]$SHA256)
. (Join-Path $PSScriptRoot 'Commun.ps1')
Load-Lab
$temp = Join-Path $LabDir 'serveur.crt.part'
try {
 & curl.exe --noproxy '*' --fail --show-error --max-time 10 "http://$($Lab.Web)/serveur.crt" -o $temp
 if ($LASTEXITCODE -ne 0) { throw 'Téléchargement du certificat public en échec.' }
 Assert-Hash $temp $SHA256
 Move-Item -LiteralPath $temp -Destination (Join-Path $LabDir 'serveur.crt') -Force
 $SHA256.ToLowerInvariant() | Set-Content -LiteralPath (Join-Path $LabDir 'serveur.sha256') -Encoding ASCII
} finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp } }
Invoke-LabWeb 'HTTP_direct' "http://$($Lab.Web)/index.html"
Invoke-LabWeb 'HTTPS_direct' "https://$($Lab.Web)/index.html" (Join-Path $LabDir 'serveur.crt')

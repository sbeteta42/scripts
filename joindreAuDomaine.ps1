# sbeteta@beteta.org
#Set-ExecutionPolicy RemoteSigned -Force


$user = "administrateur@Formation.lan"
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($User, $password)

Add-Computer -NewName pc01 -DomainName Formation.lan -Credential $Cred -Restart -Force

 

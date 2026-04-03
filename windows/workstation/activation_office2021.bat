Echo - LANCE DE LA PROCEDURE ACTIVATION Microsoft Office 2021 LTSC
ECHO ----------------------------------------------------------------
cd /d %ProgramFiles(x86)%\Microsoft Office\Office16
echo - Installation de la clé de licence en volume pour Office 2021
for /f %x in ('dir /b ..\root\Licenses16\ProPlus2021VL_KMS*.xrm-ms') do cscript ospp.vbs /inslic:"..\root\Licenses16\%x"
echo - Activation de Microsoft Office 2021.. Please wail ...
echo -------------------------------------------------------
cscript ospp.vbs /setprt:1688
cscript ospp.vbs /unpkey:6F7TH >nul
cscript ospp.vbs /inpkey:FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH
cscript ospp.vbs /sethst:s8.uk.to
cscript ospp.vbs /act

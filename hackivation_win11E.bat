@echo off
title Activation de Windows 11 Entreprise pour les formateurs MVP Microsoft
@echo - Installation de la clé de licence Windows 11 Enterprise
slmgr /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43
@echo - Activation de la licence en ligne.. please wait... 
slmgr /skms kms8.msguides.com
slmgr /ato
@echo - Licence Windows 11 Enterprise activé !

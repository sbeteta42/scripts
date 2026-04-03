@echo off
title Activation Windows Server 2019 &cls&echo ============================================================================&echo #Projet: Activation Microsoft WindowsServer 2019 pour formation &echo ============================================================================&echo.&echo #Support:&echo https://www.beteta.org&echo.&echo.&echo ============================================================================&echo Activation de Windows Server...&set i=1

REM installation de la cle de licence
slmgr /ipk N69G4-B89J2-4G8F4-WWYCC-J464C

REM connexion au KMS server en ligne
slmgr /skms kms8.msguides.com

REM Activation de la licence
slmgr /ato

@echo off
title Activation Windows 11 &cls&echo ============================================================================&echo #Projet: Activation Microsoft Windows 10 Entreprise pour formation &echo ============================================================================&echo.&echo #Support:&echo https://www.beteta.org&echo.&echo.&echo ============================================================================&echo Activation de Windows 11...&set i=1

REM installation de la cle de licence
slmgr /ipk NPPR9-FWDCX-D2C8J-H872K-2YT43

REM connexion au KMS server en ligne
slmgr /skms kms8.msguides.com

REM Activation de la licence
slmgr /ato
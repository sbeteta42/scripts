@echo off
title Activation Windows Server 2025 &cls&echo ============================================================================&echo #Projet: Activation Microsoft WindowsServer 2025 pour formation &echo ============================================================================&echo.&echo #Support:&echo https://www.beteta.org&echo.&echo.&echo ============================================================================&echo Activation de Windows Server...&set i=1

REM installation de la cle de licence
slmgr /ipk TVRH6-WHNXV-R9WG3-9XRFY-MY832

REM connexion au KMS server en ligne
slmgr /skms kms8.msguides.com

REM Activation de la licence
slmgr /ato

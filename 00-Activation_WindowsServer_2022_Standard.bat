@echo off
title Activation Windows Server 2022 &cls&echo ============================================================================&echo #Projet: Activation Microsoft WindowsServer 2022 pour formation &echo ============================================================================&echo.&echo #Support:&echo https://www.beteta.org&echo.&echo.&echo ============================================================================&echo Activation de Windows Server...&set i=1

REM installation de la cle de licence
slmgr /ipk VDYBN-27WPP-V4HQT-9VMD4-VMK7H

REM connexion au KMS server en ligne
slmgr /skms kms8.msguides.com

REM Activation de la licence
slmgr /ato

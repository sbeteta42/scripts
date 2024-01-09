@echo off
title Activation Windows 10 &cls&echo ============================================================================&echo #Projet: Activation Microsoft Windows 10 pour formation &echo ============================================================================&echo.&echo #Support:&echo https://www.beteta.org&echo.&echo.&echo ============================================================================&echo Activation de Windows 10...&set i=1

REM installation de la cle de licence
slmgr /ipk RW7WN-FMT44-KRGBK-G44WK-QV7YK

REM connexion au KMS server en ligne
slmgr /skms kms8.msguides.com

REM Activation de la licence
slmgr /ato

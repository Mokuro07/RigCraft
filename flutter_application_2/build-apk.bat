@echo off
title RigCraft UI - Bangun APK
cd /d "%~dp0"
echo ================================================
echo  RigCraft UI - membangun berkas APK
echo ================================================
echo.
echo Proses ini memakan waktu beberapa menit pada pemakaian pertama.
echo Hasil akhir:
echo   build\app\outputs\flutter-apk\app-release.apk
echo.
echo Gunakan APK ini untuk memasang aplikasi ke HP Android asli
echo (salin ke HP, lalu ketuk berkasnya dan izinkan pemasangan).
echo.
set PATH=C:\flutter\bin;%PATH%
call flutter pub get
echo.
call flutter build apk --release
echo.
echo ================================================
echo  Selesai. Berkas APK ada di:
echo  %~dp0build\app\outputs\flutter-apk\app-release.apk
echo ================================================
pause

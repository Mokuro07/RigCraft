@echo off
title RigCraft UI - Jalankan di Chrome
cd /d "%~dp0"
echo ================================================
echo  RigCraft UI - menjalankan aplikasi di Chrome
echo ================================================
echo.
echo Yang akan terjadi:
echo  1. Memasang dependensi paket (flutter pub get)
echo  2. Membuka Chrome dengan aplikasi RigCraft UI
echo.
echo Cara tercepat melihat tampilan tanpa emulator.
echo Untuk menghentikan: tekan q di jendela ini.
echo.
echo Catatan: di Chrome tampilan berbentuk halaman web (lebar),
echo bukan layar ponsel. Gunakan run-emulator.bat untuk bentuk mobile.
echo.
set PATH=C:\flutter\bin;%PATH%
call flutter pub get
echo.
call flutter run -d chrome
echo.
echo Aplikasi dihentikan.
pause

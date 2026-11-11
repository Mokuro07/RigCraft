@echo off
title RigCraft UI - Jalankan di Emulator Android
cd /d "%~dp0"
echo ================================================
echo  RigCraft UI - menjalankan di emulator Android
echo ================================================
echo.
echo Yang akan terjadi:
echo  1. Memasang dependensi paket (flutter pub get)
echo  2. Menampilkan daftar emulator yang tersedia
echo  3. Menyalakan emulator Medium_Phone (perlu 1-2 menit)
echo  4. Memasang dan menjalankan aplikasi RigCraft UI
echo.
echo Jendela emulator akan terbuka sendiri.
echo Tunggu sampai tampilan aplikasi muncul.
echo Untuk menghentikan: tekan q di jendela ini.
echo.
set PATH=C:\flutter\bin;%PATH%
call flutter pub get
echo.
call flutter emulators
echo.
echo Menyalakan emulator Medium_Phone...
start "" /min cmd /c "flutter emulators --launch Medium_Phone"
echo Menunggu emulator siap (60 detik)...
timeout /t 60 /nobreak >nul
call flutter run -d emulator-5554
echo.
echo Aplikasi dihentikan.
pause

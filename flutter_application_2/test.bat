@echo off
title RigCraft UI - Uji
cd /d "%~dp0"
echo ================================================
echo  RigCraft UI - menjalankan pengujian
echo ================================================
echo.
echo Dua tahap: cek statis (analyze) lalu uji asap (test).
echo Keduanya harus berakhir dengan "No issues found" dan "All tests passed".
echo.
set PATH=C:\flutter\bin;%PATH%
call flutter pub get
echo.
echo --- Tahap 1: cek statis ---
call flutter analyze
echo.
echo --- Tahap 2: uji asap ---
call flutter test
echo.
pause

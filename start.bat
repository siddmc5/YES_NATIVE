@echo off
title Yes Native Vendor
echo ====================================
echo  Yes Native Vendor - Launching...
echo ====================================
echo.

:: Start the backend server in a new window
echo [1/2] Starting backend server...
start "Backend Server" cmd /c "cd /d C:\Users\siddh\Downloads\vendor\backend && node server.js"

:: Give the backend a moment to boot up
echo Waiting for backend...
timeout /t 3 /nobreak >nul

:: Start the Flutter app in Chrome
echo [2/2] Launching Flutter app...
echo.
cd /d C:\Users\siddh\Downloads\vendor
flutter run -d chrome

echo.
pause

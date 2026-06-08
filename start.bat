@echo off
title Yes Native Vendor
echo ====================================
echo  Yes Native Vendor - Launching...
echo ====================================
echo.

:: Start the backend server in a new window
echo [1/2] Starting backend server...
start "Backend Server" cmd /k "cd /d "%~dp0backend" && npm install && npm run dev"

:: Give the backend a moment to boot up
echo Waiting for backend...
timeout /t 5 /nobreak >nul

:: Start the Flutter app in Edge
echo [2/2] Launching Flutter app...
echo.
cd /d "%~dp0"
flutter run -d edge

echo.
pause

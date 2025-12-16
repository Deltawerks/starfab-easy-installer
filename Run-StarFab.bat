@echo off
echo === StarFab Easy Installer ===
echo.
echo Starting installer... (This may take a few minutes on first run)
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0Run-StarFab.ps1"
pause

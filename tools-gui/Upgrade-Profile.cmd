@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0Upgrade-Profile.ps1"
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
    echo Launcher exited with code %EXITCODE%. Run Upgrade-Profile.ps1 from PowerShell to see errors.
    pause >nul
)
endlocal & exit /b %EXITCODE%

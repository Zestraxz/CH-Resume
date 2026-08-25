@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0New-Launcher.ps1"
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
    echo Launcher exited with code %EXITCODE%. Run New-Launcher.ps1 from PowerShell to see errors.
    pause >nul
)
endlocal & exit /b %EXITCODE%

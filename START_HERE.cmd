@echo off
setlocal
REM ============================================================================
REM Resume — One-click startup
REM ============================================================================
REM Bootstraps environment, brings up services, opens the app in browser.
REM Calls scripts\00-start\start-fullstack.ps1 as the source of truth.
REM ============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\00-start\start-fullstack.ps1"
set "STARTUP_EXIT_CODE=%ERRORLEVEL%"

if not "%STARTUP_EXIT_CODE%"=="0" (
    echo.
    echo ====================================================================
    echo Startup failed with exit code %STARTUP_EXIT_CODE%.
    echo Check the output above for errors.
    echo Press any key to close this window.
    echo ====================================================================
    pause >nul
)

endlocal & exit /b %STARTUP_EXIT_CODE%

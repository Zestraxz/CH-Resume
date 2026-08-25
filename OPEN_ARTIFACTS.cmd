@echo off
setlocal
REM ============================================================================
REM Resume — Open docs, README, and key URLs
REM ============================================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\00-start\open-project-artifacts.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
    echo.
    echo Failed to open artifacts. Exit code: %EXIT_CODE%
    pause >nul
)

endlocal & exit /b %EXIT_CODE%

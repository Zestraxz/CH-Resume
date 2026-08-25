#Requires -Version 5.1
<#
.SYNOPSIS
    Resume - Windows bootstrap.

.DESCRIPTION
    Idempotent setup script. Checks prerequisites, creates .env, installs deps,
    brings up services. Safe to re-run.

.PARAMETER SkipDeps
    Skip dependency install (pnpm install / pip install).

.PARAMETER SkipDocker
    Skip Docker compose up.

.PARAMETER OpenBrowser
    Open the app in browser after services are healthy.

.EXAMPLE
    .\01_setup\run.ps1
    .\01_setup\run.ps1 -OpenBrowser
    .\01_setup\run.ps1 -SkipDocker
#>

[CmdletBinding()]
param(
    [switch]$SkipDeps,
    [switch]$SkipDocker,
    [switch]$OpenBrowser
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Write-Step  { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok    { param($Msg) Write-Host "    OK: $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "    WARN: $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "    FAIL: $Msg" -ForegroundColor Red }

function Test-Command {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

# ---- 1. Prerequisites -------------------------------------------------------
Write-Step "Checking prerequisites"

$missing = @()
if (-not (Test-Command 'git'))     { $missing += 'git' }
if (-not (Test-Command 'docker'))  { $missing += 'docker' }
if ((Test-Path 'package.json') -and -not (Test-Command 'node')) { $missing += 'node' }
if ((Test-Path 'package.json') -and -not (Test-Command 'pnpm')) { $missing += 'pnpm' }
if ((Test-Path 'pyproject.toml') -and -not (Test-Command 'python')) { $missing += 'python' }

if ($missing.Count -gt 0) {
    Write-Fail "Missing prerequisites: $($missing -join ', ')"
    Write-Host ""
    Write-Host "Install instructions:" -ForegroundColor Yellow
    Write-Host "  - Node + pnpm: https://nodejs.org and 'npm install -g pnpm'"
    Write-Host "  - Python:      https://python.org"
    Write-Host "  - Docker:      https://docker.com/products/docker-desktop"
    exit 1
}
Write-Ok "All prerequisites present"

# ---- 2. .env ----------------------------------------------------------------
Write-Step "Checking .env"
if (-not (Test-Path '.env')) {
    if (Test-Path '.env.example') {
        Copy-Item '.env.example' '.env'
        Write-Warn ".env created from .env.example - edit it before deploying to prod"
    } else {
        Write-Warn "No .env.example found - skipping"
    }
} else {
    Write-Ok ".env present"
}

# ---- 3. Dependencies --------------------------------------------------------
if (-not $SkipDeps) {
    if (Test-Path 'package.json') {
        Write-Step "Installing Node dependencies (pnpm install)"
        pnpm install
        if ($LASTEXITCODE -ne 0) { Write-Fail "pnpm install failed"; exit 1 }
        Write-Ok "Node deps installed"
    }
    if (Test-Path 'pyproject.toml') {
        Write-Step "Installing Python dependencies (pip install -e '.[dev]')"
        python -m pip install -e '.[dev]'
        if ($LASTEXITCODE -ne 0) { Write-Fail "pip install failed"; exit 1 }
        Write-Ok "Python deps installed"
    }
} else {
    Write-Warn "Skipping dependency install (-SkipDeps)"
}

# ---- 4. Docker (delegated to scripts/00-start/start-fullstack.ps1) ---------
if (-not $SkipDocker -and (Test-Path 'docker-compose.yml')) {
    $fullstack = Join-Path $ProjectRoot 'scripts\00-start\start-fullstack.ps1'
    if (Test-Path $fullstack) {
        Write-Step "Delegating Docker bring-up to scripts/00-start/start-fullstack.ps1"
        $args = @()
        if (-not $OpenBrowser) { $args += '-NoOpen' }
        & $fullstack @args
        if ($LASTEXITCODE -ne 0) { Write-Fail "start-fullstack failed"; exit 1 }
    } else {
        Write-Warn "scripts/00-start/start-fullstack.ps1 not found; skipping Docker step"
    }
} else {
    if ($SkipDocker) { Write-Warn "Skipping Docker (-SkipDocker)" }
}

# ---- Done -------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " Resume is ready." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host " App:      http://localhost:3000"
Write-Host " API:      http://localhost:8000"
Write-Host " API docs: http://localhost:8000/docs"
Write-Host ""
Write-Host " Next:"
Write-Host "   - Read STATUS.md  (current phase)"
Write-Host "   - Read CLAUDE.md  (AI workflow conventions)"
Write-Host "   - pnpm dev        (start dev server, if not Docker)"
Write-Host ""

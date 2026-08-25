#Requires -Version 5.1
<#
.SYNOPSIS
    Resume - Full-stack startup (Docker + browser open).

.DESCRIPTION
    Called by START_HERE.cmd. Detects Docker Desktop, starts services, waits for
    healthchecks, opens browser. Idempotent.

.PARAMETER NoOpen
    Don't open browser after services are healthy.
#>

[CmdletBinding()]
param([switch]$NoOpen)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

function Write-Step  { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok    { param($Msg) Write-Host "    OK: $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "    WARN: $Msg" -ForegroundColor Yellow }
function Write-Fail  { param($Msg) Write-Host "    FAIL: $Msg" -ForegroundColor Red }

# ---- 1. Detect Docker -------------------------------------------------------
Write-Step "Checking Docker Desktop"
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerCmd) {
    Write-Fail "Docker CLI not on PATH. Install Docker Desktop: https://docker.com/products/docker-desktop"
    exit 1
}

docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Docker daemon not running - attempting to start Docker Desktop"
    $candidates = @(
        "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
        "${env:ProgramFiles(x86)}\Docker\Docker\Docker Desktop.exe"
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) {
        # Registry fallback
        try {
            $regKey = Get-ItemProperty 'HKLM:\SOFTWARE\Docker Inc.\Docker Desktop' -ErrorAction Stop
            $exe = Join-Path $regKey.AppPath 'Docker Desktop.exe'
        } catch {}
    }
    if (-not $exe -or -not (Test-Path $exe)) {
        Write-Fail "Docker Desktop.exe not found. Install from https://docker.com"
        exit 1
    }

    Start-Process $exe
    Write-Host "    Waiting up to 90s for Docker..." -ForegroundColor Yellow
    $deadline = (Get-Date).AddSeconds(90)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 3
        docker info 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { break }
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Docker did not start within 90s. Try opening Docker Desktop manually and re-run."
        exit 1
    }
}
Write-Ok "Docker is running"

# ---- 2. .env ----------------------------------------------------------------
Write-Step "Checking .env"
if (-not (Test-Path '.env')) {
    if (Test-Path '.env.example') {
        Copy-Item '.env.example' '.env'
        Write-Warn ".env created from .env.example - edit before prod"
    }
}
Write-Ok ".env present"

# ---- 3. Bring up services ---------------------------------------------------
Write-Step "docker compose up -d --build"
docker compose up -d --build
if ($LASTEXITCODE -ne 0) { Write-Fail "docker compose up failed"; exit 1 }
Write-Ok "Services started"

# ---- 4. Wait for healthchecks ----------------------------------------------
Write-Step "Waiting for services to be healthy"

$services = @(
    @{ Name = 'postgres'; Cmd = { docker compose exec -T postgres pg_isready 2>&1 | Out-Null; $LASTEXITCODE -eq 0 } },
    @{ Name = 'redis';    Cmd = { docker compose exec -T redis redis-cli ping 2>&1 | Out-String -OutVariable out | Out-Null; $out -match 'PONG' } }
)

# Add API healthcheck if route exists
$apiHealth = 'http://localhost:8000/health'
$frontUrl  = 'http://localhost:3000'

foreach ($svc in $services) {
    $deadline = (Get-Date).AddSeconds(60)
    while ((Get-Date) -lt $deadline) {
        if (& $svc.Cmd) { Write-Ok "$($svc.Name) healthy"; break }
        Start-Sleep -Seconds 2
    }
    if ((Get-Date) -ge $deadline) { Write-Warn "$($svc.Name) did not become healthy within 60s" }
}

# API healthcheck (optional)
try {
    $deadline = (Get-Date).AddSeconds(30)
    while ((Get-Date) -lt $deadline) {
        try {
            $r = Invoke-WebRequest -Uri $apiHealth -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            if ($r.StatusCode -eq 200) { Write-Ok "API healthy ($apiHealth)"; break }
        } catch { Start-Sleep -Seconds 2 }
    }
} catch {}

# ---- 5. Open browser --------------------------------------------------------
if (-not $NoOpen) {
    Write-Step "Opening browser"
    Start-Process $frontUrl
    Start-Process "$apiHealth"
}

# ---- Done -------------------------------------------------------------------
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " Resume is up." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host " Frontend: $frontUrl"
Write-Host " API:      http://localhost:8000"
Write-Host " API docs: http://localhost:8000/docs"
Write-Host ""
Write-Host " Stop with:  docker compose down"
Write-Host " Logs:       docker compose logs -f"
Write-Host ""

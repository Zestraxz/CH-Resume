#Requires -Version 5.1
<#
.SYNOPSIS
    Verify local environment: prerequisites, services up, healthchecks green.
#>

$ErrorActionPreference = 'Continue'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

$failures = 0
function Check { param($Name, [scriptblock]$Test)
    Write-Host -NoNewline "  $Name ... "
    try {
        if (& $Test) { Write-Host "OK" -ForegroundColor Green }
        else { Write-Host "FAIL" -ForegroundColor Red; $script:failures++ }
    } catch {
        Write-Host "FAIL ($_)" -ForegroundColor Red; $script:failures++
    }
}

Write-Host "Prerequisites:"
Check "git"     { $null -ne (Get-Command git -ErrorAction SilentlyContinue) }
Check "docker"  { $null -ne (Get-Command docker -ErrorAction SilentlyContinue) }
if (Test-Path 'package.json')   { Check "node"   { $null -ne (Get-Command node -ErrorAction SilentlyContinue) } }
if (Test-Path 'package.json')   { Check "pnpm"   { $null -ne (Get-Command pnpm -ErrorAction SilentlyContinue) } }
if (Test-Path 'pyproject.toml') { Check "python" { $null -ne (Get-Command python -ErrorAction SilentlyContinue) } }

Write-Host ""
Write-Host "Project files:"
Check ".env"             { Test-Path '.env' }
Check ".gitignore"       { Test-Path '.gitignore' }
Check "CLAUDE.md"        { Test-Path 'CLAUDE.md' }
Check "STATUS.md"        { Test-Path 'STATUS.md' }
Check "docker-compose.yml" { Test-Path 'docker-compose.yml' }

Write-Host ""
Write-Host "Services (Docker):"
Check "docker daemon"    { docker info 2>&1 | Out-Null; $LASTEXITCODE -eq 0 }
Check "postgres up"      { (docker compose ps --status running --services 2>$null) -match 'postgres' }
Check "redis up"         { (docker compose ps --status running --services 2>$null) -match 'redis' }

Write-Host ""
Write-Host "Healthchecks:"
Check "postgres reachable" { docker compose exec -T postgres pg_isready 2>&1 | Out-Null; $LASTEXITCODE -eq 0 }
Check "redis reachable"    { (docker compose exec -T redis redis-cli ping 2>&1) -match 'PONG' }
Check "API /health"        { try { (Invoke-WebRequest -Uri 'http://localhost:8000/health' -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200 } catch { $false } }

Write-Host ""
if ($failures -eq 0) {
    Write-Host "All checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$failures check(s) failed." -ForegroundColor Red
    exit 1
}

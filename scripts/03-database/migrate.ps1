#Requires -Version 5.1
<#
.SYNOPSIS
    Run database migrations (Prisma OR Alembic, whichever the project uses).
#>

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

if (Test-Path 'apps\api\prisma\schema.prisma') {
    Write-Host "Running Prisma migrations..." -ForegroundColor Cyan
    pnpm --filter '@*/api' prisma migrate deploy
    if ($LASTEXITCODE -ne 0) { exit 1 }
    Write-Host "OK: Prisma migrations applied" -ForegroundColor Green
}
elseif ((Test-Path 'alembic.ini') -or (Test-Path 'apps\api\alembic.ini')) {
    Write-Host "Running Alembic migrations..." -ForegroundColor Cyan
    alembic upgrade head
    if ($LASTEXITCODE -ne 0) { exit 1 }
    Write-Host "OK: Alembic migrations applied" -ForegroundColor Green
}
else {
    Write-Host "No migrations system detected (no Prisma schema or alembic.ini)." -ForegroundColor Yellow
    exit 0
}

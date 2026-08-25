#Requires -Version 5.1
<#
.SYNOPSIS
    Ensure .env exists. Generate secrets for placeholder values.
#>

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

function New-Secret {
    param([int]$Bytes = 32)
    $bytes = New-Object byte[] $Bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    [Convert]::ToBase64String($bytes)
}

if (-not (Test-Path '.env.example')) {
    Write-Host "No .env.example found - nothing to bootstrap." -ForegroundColor Yellow
    exit 0
}

if (Test-Path '.env') {
    Write-Host ".env already exists - leaving it alone." -ForegroundColor Yellow
    exit 0
}

Write-Host "Bootstrapping .env from .env.example..." -ForegroundColor Cyan
$content = Get-Content '.env.example' -Raw

# Auto-generate secrets for common placeholders
$replacements = @{
    'change-me-in-prod'                       = (New-Secret 32)
    'change-me-to-a-long-random-string'       = (New-Secret 48)
}
foreach ($key in $replacements.Keys) {
    $content = $content.Replace($key, $replacements[$key])
}

Set-Content -Path '.env' -Value $content -NoNewline
Write-Host "OK: .env created. Review it before deploying." -ForegroundColor Green

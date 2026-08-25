#Requires -Version 5.1
<#
.SYNOPSIS
    Open README, docs, and key project URLs.
#>

$ErrorActionPreference = 'Continue'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $ProjectRoot

function Open-File   { param($p) if (Test-Path $p) { Invoke-Item $p } }
function Open-Url    { param($u) Start-Process $u }
function Open-Folder { param($p) if (Test-Path $p) { Invoke-Item $p } }

Write-Host "Opening project artifacts..." -ForegroundColor Cyan

# Markdown docs (open in default editor / browser)
Open-File '.\README.md'
Open-File '.\STATUS.md'
Open-File '.\START_HERE.md'
Open-File '.\CLAUDE.md'

# Folders
Open-Folder '.\docs'
Open-Folder '.\02_active'

# URLs (only if Docker is up - silent fail otherwise)
try {
    docker compose ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Open-Url 'http://localhost:3000'
        Open-Url 'http://localhost:8000/docs'
    }
} catch {}

Write-Host "Done." -ForegroundColor Green

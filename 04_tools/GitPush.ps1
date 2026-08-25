#Requires -Version 5.1
<#
.SYNOPSIS
    Safe git push - runs lint/test/typecheck gate before pushing.

.DESCRIPTION
    Standard "ship it" script. Stages SPECIFIC files (not -A), runs the precommit
    gate, commits with the supplied message, and pushes upstream.

    NEVER bypasses hooks. NEVER force-pushes. NEVER commits .env.

.PARAMETER Message
    Commit message (Conventional Commits format recommended).

.PARAMETER Files
    Specific files to stage. If omitted, lists modified files for confirmation.

.PARAMETER NoTest
    Skip the test step (lint + typecheck still run).

.PARAMETER DryRun
    Print what would happen without staging/committing/pushing.

.EXAMPLE
    .\04_tools\GitPush.ps1 -Message "feat(api): add /cases/:id endpoint" -Files apps/api/src/routes/cases.ts,apps/api/tests/routes/cases.test.ts
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Message,
    [string[]]$Files,
    [switch]$NoTest,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Write-Step { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param($Msg) Write-Host "    OK: $Msg" -ForegroundColor Green }
function Write-Fail { param($Msg) Write-Host "    FAIL: $Msg" -ForegroundColor Red }

# ---- 1. Sanity --------------------------------------------------------------
Write-Step "Sanity check"

# Refuse to commit .env or secrets
$forbidden = @('.env', 'credentials.json', 'secrets.json')
foreach ($f in $Files) {
    if ($forbidden -contains (Split-Path $f -Leaf)) {
        Write-Fail "Refusing to commit forbidden file: $f"
        exit 1
    }
}

# Confirm branch
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
Write-Host "    Branch: $branch"
if ($branch -in @('main', 'master', 'production')) {
    Write-Host "    !! Pushing to a protected branch. Confirm? [y/N]" -ForegroundColor Yellow
    $ans = Read-Host
    if ($ans -ne 'y' -and $ans -ne 'Y') { Write-Host "Aborted."; exit 1 }
}

# ---- 2. List modified ------------------------------------------------------
if (-not $Files) {
    Write-Step "Modified files (none specified - listing for confirmation)"
    git status --short
    Write-Host ""
    Write-Host "Re-run with -Files <comma-separated-list> to stage specific files." -ForegroundColor Yellow
    exit 0
}

# ---- 3. Precommit gate -----------------------------------------------------
Write-Step "Running precommit gate"

$steps = @(
    @{ Name = 'format'; Cmd = 'pnpm format' },
    @{ Name = 'lint';   Cmd = 'pnpm lint' },
    @{ Name = 'typecheck'; Cmd = 'pnpm typecheck' }
)
if (-not $NoTest) {
    $steps += @{ Name = 'test'; Cmd = 'pnpm test' }
}

foreach ($s in $steps) {
    if ($DryRun) {
        Write-Host "    DRY-RUN: would run $($s.Cmd)" -ForegroundColor Yellow
    } else {
        Write-Host "    -> $($s.Cmd)" -ForegroundColor Gray
        Invoke-Expression $s.Cmd
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "$($s.Name) failed. Fix before pushing."
            exit 1
        }
    }
}
Write-Ok "Precommit gate passed"

# ---- 4. Stage --------------------------------------------------------------
Write-Step "Staging files"
foreach ($f in $Files) {
    if ($DryRun) {
        Write-Host "    DRY-RUN: would git add $f" -ForegroundColor Yellow
    } else {
        git add $f
        if ($LASTEXITCODE -ne 0) { Write-Fail "git add $f failed"; exit 1 }
        Write-Host "    + $f"
    }
}

# ---- 5. Commit -------------------------------------------------------------
Write-Step "Committing"
if ($DryRun) {
    Write-Host "    DRY-RUN: would git commit -m '$Message'" -ForegroundColor Yellow
} else {
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) { Write-Fail "git commit failed"; exit 1 }
    Write-Ok "Committed"
}

# ---- 6. Push ---------------------------------------------------------------
Write-Step "Pushing"
if ($DryRun) {
    Write-Host "    DRY-RUN: would git push" -ForegroundColor Yellow
} else {
    git push
    if ($LASTEXITCODE -ne 0) { Write-Fail "git push failed"; exit 1 }
    Write-Ok "Pushed"
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green

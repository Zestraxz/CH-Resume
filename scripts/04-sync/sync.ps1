#Requires -Version 5.1
<#
.SYNOPSIS
    Sync project's .claude/, agents/, skills/, commands/, hooks/, rules/ with live ~/.claude/.

.DESCRIPTION
    Directional sync between this project's AI config and the user's live ~/.claude.

    BEHAVIOR (be aware):
      - Copies files; **overwrites** existing files at destination (Copy-Item -Force).
      - Never deletes files at destination that are absent in source.
      - With -Backup, existing destination files are copied to <file>.bak.<timestamp>
        before being overwritten. Recommended for first runs.

    Default: Push (project -> live). Use -Direction Pull or Both to reverse.

.PARAMETER Direction
    Push (default): project -> live
    Pull: live -> project
    Both: bidirectional reconciliation (overwrites in both directions)

.PARAMETER Items
    Which top-level folders to sync. Default: agents, skills, commands, rules.
    Excludes hooks (opt-in via explicit pass) since hook changes have wider blast radius.

.PARAMETER Backup
    Before overwriting an existing destination file, copy it to <file>.bak.<yyyyMMdd-HHmmss>.

.PARAMETER DryRun
    Print what would be copied without copying.

.EXAMPLE
    .\scripts\04-sync\sync.ps1 -DryRun
    .\scripts\04-sync\sync.ps1 -Backup
    .\scripts\04-sync\sync.ps1 -Direction Pull
    .\scripts\04-sync\sync.ps1 -Items agents,skills,commands,hooks
#>

[CmdletBinding()]
param(
    [ValidateSet('Push', 'Pull', 'Both')]
    [string]$Direction = 'Push',
    [string[]]$Items = @('agents', 'skills', 'commands', 'rules'),
    [switch]$Backup,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$LiveRoot    = Join-Path $env:USERPROFILE '.claude'

if (-not (Test-Path $LiveRoot)) {
    Write-Host "Live ~/.claude not found at $LiveRoot" -ForegroundColor Yellow
    Write-Host "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
}

$Exclusions = @('*.bak.*', '.git', 'node_modules', '*.lock', '.DS_Store', 'Thumbs.db')

function Sync-Folder {
    param([string]$From, [string]$To, [string]$Label)

    if (-not (Test-Path $From)) {
        Write-Host "  [$Label] $From - skip (not present)" -ForegroundColor Gray
        return
    }
    if (-not (Test-Path $To)) {
        if ($DryRun) { Write-Host "  [$Label] mkdir $To" -ForegroundColor Yellow }
        else { New-Item -ItemType Directory -Path $To -Force | Out-Null }
    }

    $copyArgs = @('-Recurse', '-Force')
    if ($DryRun) { $copyArgs += '-WhatIf' }

    Write-Host "  [$Label] $From -> $To" -ForegroundColor Cyan
    Get-ChildItem -Path $From -Recurse | Where-Object {
        $name = $_.Name
        -not ($Exclusions | Where-Object { $name -like $_ })
    } | ForEach-Object {
        $rel = $_.FullName.Substring($From.Length).TrimStart('\', '/')
        $dest = Join-Path $To $rel
        if ($DryRun) {
            Write-Host "    DRY: $($_.FullName) -> $dest" -ForegroundColor Yellow
        } else {
            if ($_.PSIsContainer) {
                if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
            } else {
                $destDir = Split-Path $dest
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                if ($Backup -and (Test-Path $dest)) {
                    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
                    Copy-Item -Path $dest -Destination "$dest.bak.$stamp" -Force
                }
                Copy-Item -Path $_.FullName -Destination $dest -Force
            }
        }
    }
}

foreach ($item in $Items) {
    $projectPath = Join-Path $ProjectRoot $item
    $livePath    = Join-Path $LiveRoot    $item

    switch ($Direction) {
        'Push' { Sync-Folder -From $projectPath -To $livePath -Label "Push:$item" }
        'Pull' { Sync-Folder -From $livePath -To $projectPath -Label "Pull:$item" }
        'Both' {
            Sync-Folder -From $projectPath -To $livePath -Label "Push:$item"
            Sync-Folder -From $livePath -To $projectPath -Label "Pull:$item"
        }
    }
}

Write-Host ""
Write-Host "Sync complete ($Direction)." -ForegroundColor Green

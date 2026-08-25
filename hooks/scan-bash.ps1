#Requires -Version 5.1
<#
.SYNOPSIS
    PreToolUse hook - scan Bash invocations for dangerous patterns.

.DESCRIPTION
    Wired into hooks/hooks.json under PreToolUse with matcher "Bash".
    Reads tool input via $env:CLAUDE_TOOL_INPUT (JSON).
    Exits 1 to BLOCK the tool call if a dangerous pattern is detected.
#>

$ErrorActionPreference = 'Stop'

$inputJson = $env:CLAUDE_TOOL_INPUT
if (-not $inputJson) { exit 0 }  # no input - allow

$cmd = ""
try {
    $parsed = $inputJson | ConvertFrom-Json
    $cmd = $parsed.command
} catch { exit 0 }  # parse error - allow (other hooks will deal)

if (-not $cmd) { exit 0 }

# Dangerous patterns to block
$dangerous = @(
    'rm\s+-rf\s+(/|\$HOME|~)\s*$',
    'rm\s+-rf\s+/(?!tmp|var/tmp)',
    ':\(\)\s*\{\s*:\s*\|\s*:',          # fork bomb
    'curl\s+[^|]*\|\s*(bash|sh|zsh)',   # curl | sh
    'wget\s+[^|]*\|\s*(bash|sh|zsh)',
    'mkfs\.',                            # filesystem format
    'dd\s+if=.*of=/dev/(sd|nvme|hd)',   # raw disk write
    '>\s*/dev/(sda|nvme|hda)',
    'chmod\s+-R\s+777\s+/',
    'history\s+-c',                      # history wipe
    '\.bash_history\s*&&\s*history\s+-c',
    'sudo\s+rm\s+-rf'
)

foreach ($pat in $dangerous) {
    if ($cmd -match $pat) {
        Write-Host "BLOCKED: dangerous bash pattern matched: $pat" -ForegroundColor Red
        Write-Host "Command: $cmd" -ForegroundColor Yellow
        Write-Host "If this is intentional, run it manually outside Claude." -ForegroundColor Yellow
        exit 1
    }
}

# Allow
exit 0

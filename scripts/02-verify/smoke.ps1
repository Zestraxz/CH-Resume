#Requires -Version 5.1
<#
.SYNOPSIS
    Smoke test: hit key endpoints and assert basic functionality.
#>

$ErrorActionPreference = 'Continue'

$failures = 0
function Assert { param($Name, [scriptblock]$Test)
    Write-Host -NoNewline "  $Name ... "
    try {
        if (& $Test) { Write-Host "OK" -ForegroundColor Green }
        else { Write-Host "FAIL" -ForegroundColor Red; $script:failures++ }
    } catch {
        Write-Host "FAIL ($_)" -ForegroundColor Red; $script:failures++
    }
}

$api = 'http://localhost:8000'
$web = 'http://localhost:3000'

Write-Host "Smoke tests:"
Assert "API /health 200" {
    (Invoke-WebRequest -Uri "$api/health" -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200
}
Assert "API /health body ok" {
    (Invoke-RestMethod -Uri "$api/health" -TimeoutSec 5).status -eq 'ok'
}
Assert "Frontend reachable" {
    (Invoke-WebRequest -Uri $web -UseBasicParsing -TimeoutSec 5).StatusCode -eq 200
}

Write-Host ""
if ($failures -eq 0) {
    Write-Host "Smoke passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$failures smoke check(s) failed." -ForegroundColor Red
    exit 1
}

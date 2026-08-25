<#
.SYNOPSIS
  Port the Critic kit (Radar + Microscope) into any repository.

.DESCRIPTION
  Idempotent: safe to re-run. Existing files are kept unless -Force is passed.
  The coverage map and ledger are NEVER overwritten — they hold your accumulated history.

  Windows PowerShell 5.1 compatible.

.EXAMPLE
  .\install.ps1 -Target C:\code\other-repo

.EXAMPLE
  .\install.ps1 -PrintSchedule
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)] [string] $Target = ".",
  [switch] $Force,
  [switch] $NoWorkflow,
  [switch] $DryRun,
  [switch] $PrintSchedule,
  [string] $DocsDir = "docs/04-quality/critic"
)

$ErrorActionPreference = "Stop"

function Write-Ok   { param($m) Write-Host "  + $m" -ForegroundColor Green }
function Write-Skip { param($m) Write-Host "  . $m (exists, kept)" -ForegroundColor DarkGray }
function Write-Warn { param($m) Write-Host "  ! $m" -ForegroundColor Yellow }

if ($PrintSchedule) {
  @"
Activate the weekly Radar (subscription auth - no API credits):

  claude setup-token                     # requires a Claude subscription; prints a long-lived token
  gh secret set CLAUDE_CODE_OAUTH_TOKEN  # or: Settings > Secrets and variables > Actions

Then PROVE it fires (an unfired scheduler is the failure this kit exists to prevent):

  gh workflow run self-critic.yml
  gh run list --workflow=self-critic.yml

Schedule: read it from .github/workflows/self-critic.yml - do not trust a value restated in prose.
GitHub honours 'schedule:' on the DEFAULT BRANCH only, disables scheduled workflows after ~60 days
of repo inactivity, and may delay or drop top-of-hour schedules entirely - see SOP section 4.
"@ | Write-Host
  exit 0
}

$src = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path (Join-Path $src "Critic-Radar.md"))) {
  throw "Source does not look like a .Critic folder: $src"
}
if (-not (Test-Path $Target -PathType Container)) {
  throw "Target is not a directory: $Target"
}
$tgt = (Resolve-Path $Target).Path
if ($src -eq (Join-Path $tgt ".Critic")) { throw "Source and destination are the same folder" }

$repo = Split-Path -Leaf $tgt
$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")

Push-Location $tgt
try {
  # PS 5.1 + ErrorActionPreference 'Stop': redirecting a NATIVE command's stderr (2>&1 or
  # 2>$null) wraps lines like "fatal: not a git repository" into a terminating
  # NativeCommandError - which killed this installer on every non-git target (it runs
  # BEFORE git init when called from New-Project.ps1). Probe with Test-Path instead
  # (.git may be a directory or a worktree file) and relax EAP only around the origin lookup.
  if (Test-Path '.git') {
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $origin = (git remote get-url origin 2>$null)
    $originOk = ($LASTEXITCODE -eq 0)
    $ErrorActionPreference = $prevEap
    if ($originOk -and $origin) {
      # Strip any trailing slash and the .git suffix first, then take owner/name.
      $clean = $origin.TrimEnd('/') -replace '\.git$', ''
      if ($clean -match '[:/]([^/]+/[^/]+)$') { $repo = $Matches[1] }
    }
  } else {
    Write-Warn "$tgt is not a git repository - installing anyway, but the workflow needs a GitHub remote."
  }
} finally { Pop-Location }

Write-Host ""
Write-Host "Critic kit installer" -ForegroundColor White
Write-Host "  source  $src"
Write-Host "  target  $tgt"
Write-Host "  repo    $repo"
if ($DryRun) { Write-Host "  dry run - nothing will be written" -ForegroundColor Yellow }
Write-Host ""

# Render a template with placeholders substituted. Never clobbers an existing file: the coverage
# map and ledger accumulate history that must survive a re-run.
function Copy-Template {
  param($TemplatePath, $Destination)
  if (Test-Path $Destination) { Write-Skip (Split-Path -Leaf $Destination); return }
  if (-not $DryRun) {
    $dir = Split-Path -Parent $Destination
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $body = Get-Content $TemplatePath -Raw
    $body = $body -replace '\{\{PROJECT\}\}', $repo `
                  -replace '\{\{REPO\}\}',    $repo `
                  -replace '\{\{DATE\}\}',    $date `
                  -replace '\{\{LAYER1\}\}',  'core' `
                  -replace '\{\{LAYER2\}\}',  'interface' `
                  -replace '\{\{LAYER3\}\}',  'ops'
    Set-Content -Path $Destination -Value $body -Encoding utf8
  }
  Write-Ok $Destination
}

# 1 - the kit itself
$kit = Join-Path $tgt ".Critic"
if ((Test-Path $kit) -and (-not $Force)) {
  Write-Skip ".Critic/  (use -Force to overwrite)"
} else {
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $kit | Out-Null
    Copy-Item -Path (Join-Path $src "*") -Destination $kit -Recurse -Force
  }
  Write-Ok ".Critic/"
}

# 2 - the /critic launcher
$launcher = Join-Path $tgt ".claude/commands/critic.md"
if ((Test-Path $launcher) -and (-not $Force)) {
  Write-Skip ".claude/commands/critic.md"
} else {
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $launcher) | Out-Null
    Copy-Item (Join-Path $src "templates/critic.md") $launcher -Force
  }
  Write-Ok ".claude/commands/critic.md"
}

# 3 - the Radar's memory and discipline
Copy-Template (Join-Path $src "templates/COVERAGE.md")       (Join-Path $tgt "$DocsDir/COVERAGE.md")
Copy-Template (Join-Path $src "templates/REFUTED-LEDGER.md") (Join-Path $tgt "$DocsDir/REFUTED-LEDGER.md")

# 4 - the scheduler
if ($NoWorkflow) {
  Write-Warn "workflow skipped (-NoWorkflow) - nothing will run the Radar on a schedule"
} else {
  $wf = Join-Path $tgt ".github/workflows/self-critic.yml"
  if ((Test-Path $wf) -and (-not $Force)) {
    Write-Skip ".github/workflows/self-critic.yml"
  } else {
    if (-not $DryRun) {
      New-Item -ItemType Directory -Force -Path (Split-Path -Parent $wf) | Out-Null
      Copy-Item (Join-Path $src "templates/self-critic.yml") $wf -Force
    }
    Write-Ok ".github/workflows/self-critic.yml  (dormant until the secret is set)"
  }
}

# 5 - git-ignore the per-pass scratch logs
$gi = Join-Path $tgt ".gitignore"
$hasRuns = $false
if (Test-Path $gi) { $hasRuns = (Get-Content $gi) -match '^_runs/?$' }
if ($hasRuns) {
  Write-Skip "_runs/ already in .gitignore"
} else {
  if (-not $DryRun) {
    Add-Content -Path $gi -Encoding utf8 -Value "`n# ---- Critic per-pass scratch logs -------------------------------------------`n_runs/"
  }
  Write-Ok "_runs/ -> .gitignore"
}

# If the binding still names another project, the Radar refuses to sweep (radar-prompt.md Step 0).
# Surfacing it here turns a confusing runtime abort into an obvious setup step.
$bindingStale = $false
$radar = Join-Path $tgt ".Critic/Critic-Radar.md"
if ((Test-Path $radar) -and ($repo -notlike "*CH-Critic")) {
  if ((Get-Content $radar) -match '^## Project binding . CH-Critic') { $bindingStale = $true }
}

Write-Host ""
Write-Host "Done. Two steps remain - the installer cannot do either for you:" -ForegroundColor White
Write-Host ""
if ($bindingStale) {
  Write-Host "  1. EDIT THE BINDING - .Critic/Critic-Radar.md still says CH-Critic." -ForegroundColor Yellow
  Write-Host "     The Radar aborts with BINDING ERROR until it names $repo."
} else {
  Write-Host "  1. EDIT THE BINDING - the 'Project binding' section at the bottom of" -ForegroundColor Yellow
  Write-Host "     .Critic/Critic-Radar.md, plus the TODOs in $DocsDir/COVERAGE.md."
}
Write-Host "     Set: coverage-map/ledger/queue paths - real layer list - provability floor -"
Write-Host "     the domain's validation authority (what the critic must NOT modify)."
Write-Host ""
Write-Host "  2. ACTIVATE THE SCHEDULE - run: .\install.ps1 -PrintSchedule" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Then: /critic works immediately; the Radar runs weekly once step 2 is done."
Write-Host ""

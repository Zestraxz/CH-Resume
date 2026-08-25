<#
.SYNOPSIS
  Back up this project's Claude Code session transcript(s) into the repo.

.DESCRIPTION
  Implements the workspace session-backup rule (origin: CH-Claude-Persistent-Brain
  MEMORY/SESSION_BACKUP_POLICY.md, decision D-010): transcripts are machine-local and the
  live context auto-compacts, so each session's transcript is exported into the repo.
  Never commit raw/unredacted transcripts; never push transcripts to public repos.
  - Resolves the machine-local transcript dir: ~/.claude/projects/<encoded-cwd>/
    (encoding rule: every non-alphanumeric character of the repo path becomes '-').
  - Copies the newest transcript (or all with -All) into docs/01-session/transcripts/.
  - Best-effort redaction of secret-shaped values (Amendment A: a net, not a guarantee;
    the pristine original always stays in ~/.claude). Use -NoRedact only for private,
    known-clean repos.
  - Size cap (Amendment B): files over -MaxMB are skipped with a pointer note.

  Windows PowerShell 5.1 compatible. ASCII only. Read-only toward ~/.claude.

.EXAMPLE
  .\scripts\04-sync\backup-session.ps1              # newest session, redacted, into this repo

.EXAMPLE
  .\scripts\04-sync\backup-session.ps1 -All -MaxMB 50
#>
[CmdletBinding()]
param(
  [string] $Repo = ".",
  [string] $OutDir = "docs/01-session/transcripts",
  [int]    $MaxMB = 25,
  [switch] $All,
  [switch] $NoRedact
)

$ErrorActionPreference = 'Stop'

$repoPath = (Resolve-Path $Repo).Path.TrimEnd('\')
$encoded  = $repoPath -replace '[^A-Za-z0-9]', '-'
$srcDir   = Join-Path $env:USERPROFILE (".claude\projects\" + $encoded)

if (-not (Test-Path $srcDir)) {
  throw "No local session directory for this repo: $srcDir (has Claude Code run here?)"
}

$files = Get-ChildItem -Path $srcDir -Filter *.jsonl | Sort-Object LastWriteTime -Descending
if (-not $files) { throw "No .jsonl transcripts found in $srcDir" }
if (-not $All)   { $files = @($files | Select-Object -First 1) }

$dest = Join-Path $repoPath $OutDir
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest | Out-Null }

# Secret-shaped patterns. Group 1+2 keep the key and separator; the value is masked.
$kvPattern    = '(?i)(api[_-]?key|apikey|secret|token|passwd|password|credential|authorization|bearer)(\\?["'']?\s*[:=]\s*\\?["'']?)([^"''\s,}\\]{6,})'
$barePatterns = @(
  'sk-ant-[A-Za-z0-9_\-]{10,}',
  'ghp_[A-Za-z0-9]{20,}',
  'github_pat_[A-Za-z0-9_]{20,}',
  'eyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{5,}'
)

$summary = @()
foreach ($f in $files) {
  $mb = [math]::Round($f.Length / 1MB, 1)
  if ($mb -gt $MaxMB) {
    Write-Host ("SKIP  {0}  ({1} MB exceeds the {2} MB cap; raw stays local per Amendment B)" -f $f.Name, $mb, $MaxMB)
    $summary += ("skipped {0} ({1} MB > cap)" -f $f.Name, $mb)
    continue
  }

  $stamp   = $f.LastWriteTime.ToString('yyyy-MM-dd')
  $outName = ("{0}-{1}.jsonl" -f $stamp, $f.BaseName)
  $outPath = Join-Path $dest $outName

  $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
  $redactions = 0

  if (-not $NoRedact) {
    $evaluator = { param($m) $m.Groups[1].Value + $m.Groups[2].Value + 'REDACTED' }
    $before = $content
    $content = [regex]::Replace($content, $kvPattern, $evaluator)
    $redactions += ([regex]::Matches($before, $kvPattern)).Count
    foreach ($p in $barePatterns) {
      $redactions += ([regex]::Matches($content, $p)).Count
      $content = [regex]::Replace($content, $p, 'REDACTED')
    }
  }

  [System.IO.File]::WriteAllText($outPath, $content, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ("OK    {0}  ({1} MB, {2} redaction(s)) -> {3}" -f $f.Name, $mb, $redactions, $outName)
  $summary += ("backed up {0} as {1} ({2} MB, {3} redactions)" -f $f.Name, $outName, $mb, $redactions)
}

Write-Host ""
Write-Host "Done. Review the diff before committing (redaction is best-effort, not a guarantee)."
Write-Host "Policy: MEMORY/SESSION_BACKUP_POLICY.md (D-010). Raw originals remain in:"
Write-Host ("  " + $srcDir)

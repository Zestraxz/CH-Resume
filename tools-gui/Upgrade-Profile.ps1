#Requires -Version 5.1
<#
.SYNOPSIS
    GUI to compare current profile to a higher profile and generate a diff report.

.DESCRIPTION
    Instantiates a fresh scaffold at the target profile into a tmp directory,
    diffs it against the current project, writes the report to
    02_active/profile-upgrade-report.md, opens it.

    DOES NOT auto-merge. Read the report, copy what you want manually.
    Standard+ profile only.
#>

[CmdletBinding()]
param()

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-File', $PSCommandPath)
    Start-Process powershell.exe -ArgumentList $a -WindowStyle Hidden
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

# Detect template-meta location (look for sibling .CH-Project-Architecture)
$parentDir = Split-Path -Parent $projectRoot
$metaDir = Join-Path $parentDir '.CH-Project-Architecture'
$initScript = Join-Path $metaDir 'init\New-Project.ps1'

if (-not (Test-Path $initScript)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Could not find CH Project Architecture meta-repo at:`n$metaDir`n`nThis tool needs access to init/New-Project.ps1 to instantiate a comparison scaffold.",
        'Upgrade-Profile', 'OK', 'Error') | Out-Null
    exit 1
}

# ---- Form ------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Upgrade-Profile - generate diff report'
$form.Size = New-Object System.Drawing.Size(620, 480)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = 'Profile Upgrade Report'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Compare current project structure against a higher profile.`r`nNo files are modified - this is informational only."
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 50)
$lblSub.Size = New-Object System.Drawing.Size(560, 40)

$lblCurr = New-Object System.Windows.Forms.Label
$lblCurr.Text = 'Current (guess based on installed files)'
$lblCurr.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblCurr.Location = New-Object System.Drawing.Point(20, 100)
$lblCurr.AutoSize = $true

# Detect current profile by checking presence of marker files
$currentProfile = if (Test-Path (Join-Path $projectRoot '.github\workflows\release.yml')) { 'enterprise' }
                  elseif (Test-Path (Join-Path $projectRoot 'docs\architecture\workspace.dsl')) { 'standard' }
                  else { 'minimal' }

$cmbCurr = New-Object System.Windows.Forms.ComboBox
$cmbCurr.Location = New-Object System.Drawing.Point(20, 120)
$cmbCurr.Size = New-Object System.Drawing.Size(200, 25)
$cmbCurr.DropDownStyle = 'DropDownList'
@('minimal', 'standard', 'enterprise') | ForEach-Object { [void]$cmbCurr.Items.Add($_) }
$cmbCurr.SelectedItem = $currentProfile

$lblTarget = New-Object System.Windows.Forms.Label
$lblTarget.Text = 'Target (compare against)'
$lblTarget.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblTarget.Location = New-Object System.Drawing.Point(240, 100)
$lblTarget.AutoSize = $true

$cmbTarget = New-Object System.Windows.Forms.ComboBox
$cmbTarget.Location = New-Object System.Drawing.Point(240, 120)
$cmbTarget.Size = New-Object System.Drawing.Size(200, 25)
$cmbTarget.DropDownStyle = 'DropDownList'
@('minimal', 'standard', 'enterprise') | ForEach-Object { [void]$cmbTarget.Items.Add($_) }
$cmbTarget.SelectedItem = if ($currentProfile -eq 'minimal') { 'standard' } else { 'enterprise' }

$lblStack = New-Object System.Windows.Forms.Label
$lblStack.Text = 'Stack to model'
$lblStack.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblStack.Location = New-Object System.Drawing.Point(20, 165)
$lblStack.AutoSize = $true

$cmbStack = New-Object System.Windows.Forms.ComboBox
$cmbStack.Location = New-Object System.Drawing.Point(20, 185)
$cmbStack.Size = New-Object System.Drawing.Size(200, 25)
$cmbStack.DropDownStyle = 'DropDownList'
@('hybrid', 'node', 'python', 'docs') | ForEach-Object { [void]$cmbStack.Items.Add($_) }
$cmbStack.SelectedIndex = 0

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = ''
$lblStatus.Location = New-Object System.Drawing.Point(20, 240)
$lblStatus.Size = New-Object System.Drawing.Size(560, 100)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = 'Generate Report'
$btnRun.Location = New-Object System.Drawing.Point(20, 380)
$btnRun.Size = New-Object System.Drawing.Size(180, 38)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = 'Flat'
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Close'
$btnCancel.Location = New-Object System.Drawing.Point(460, 380)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnRun.Add_Click({
    $btnRun.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
    $lblStatus.Text = "Instantiating $($cmbTarget.SelectedItem) profile in tmp ... (5-15s)"
    [System.Windows.Forms.Application]::DoEvents()

    $tmp = Join-Path $env:TEMP "profile-diff-$(Get-Random)"
    $report = Join-Path $projectRoot '02_active\profile-upgrade-report.md'

    try {
        # Instantiate the target profile scaffold
        $params = @{
            Name        = 'ProfileCompare'
            Destination = $tmp
            Stack       = $cmbStack.SelectedItem
            Profile     = $cmbTarget.SelectedItem
            NoGit       = $true
            NoOpen      = $true
        }
        $null = & $initScript @params *>&1

        if (-not (Test-Path $tmp)) { throw "Failed to instantiate $($cmbTarget.SelectedItem) profile" }

        # Diff: which paths exist in tmp but not in current project?
        $tmpFiles = Get-ChildItem $tmp -Recurse -File | ForEach-Object {
            $_.FullName.Substring($tmp.Length).TrimStart('\', '/')
        }
        $currentFiles = Get-ChildItem $projectRoot -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            $_.FullName.Substring($projectRoot.Length).TrimStart('\', '/')
        }

        $missing = $tmpFiles | Where-Object { $_ -notin $currentFiles -and $_ -notmatch '\\\.git\\' -and $_ -notmatch '/\.git/' }

        # Write report
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("# Profile Upgrade Report")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("> Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm') by tools-gui/Upgrade-Profile.cmd")
        [void]$sb.AppendLine("> Current profile (detected): **$($cmbCurr.SelectedItem)**")
        [void]$sb.AppendLine("> Target profile: **$($cmbTarget.SelectedItem)**")
        [void]$sb.AppendLine("> Stack modeled: **$($cmbStack.SelectedItem)**")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("## What the higher profile adds")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("**$($missing.Count) files** present in `$($cmbTarget.SelectedItem)` but missing from your current scaffold:")
        [void]$sb.AppendLine('')
        if ($missing.Count -eq 0) {
            [void]$sb.AppendLine('(your scaffold already includes everything from the target profile)')
        } else {
            foreach ($f in ($missing | Sort-Object)) {
                [void]$sb.AppendLine("- ``$f``")
            }
        }
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("## How to apply")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("This tool does NOT auto-merge. To adopt patterns:")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("1. Read each missing file in the reference scaffold (regenerated below).")
        [void]$sb.AppendLine("2. Copy files you want, one-by-one, into your project.")
        [void]$sb.AppendLine("3. Adapt placeholders (`Resume` etc.) to your project name.")
        [void]$sb.AppendLine("4. Update relevant docs (CHANGELOG, STATUS) to mark profile uplift.")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine("To re-generate a fresh reference scaffold for inspection:")
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('```powershell')
        [void]$sb.AppendLine("`$tmp = Join-Path `$env:TEMP 'profile-ref'")
        [void]$sb.AppendLine("& '$initScript' \``")
        [void]$sb.AppendLine("    -Name 'Reference' -Destination `$tmp \``")
        [void]$sb.AppendLine("    -Profile $($cmbTarget.SelectedItem) -Stack $($cmbStack.SelectedItem) \``")
        [void]$sb.AppendLine("    -NoGit -NoOpen")
        [void]$sb.AppendLine('```')

        [System.IO.File]::WriteAllText($report, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))

        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 0)
        $lblStatus.Text = "OK - Report written ($($missing.Count) candidate additions)`r`n`r`nLocation: 02_active/profile-upgrade-report.md"
        try { Invoke-Item $report } catch {}
    } catch {
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(192, 0, 0)
        $lblStatus.Text = "FAILED: $_"
    } finally {
        if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        $btnRun.Enabled = $true
    }
})

$form.Controls.AddRange(@(
    $lblTitle, $lblSub,
    $lblCurr, $cmbCurr,
    $lblTarget, $cmbTarget,
    $lblStack, $cmbStack,
    $lblStatus,
    $btnRun, $btnCancel
))
$form.AcceptButton = $btnRun
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

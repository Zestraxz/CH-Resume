#Requires -Version 5.1
<#
.SYNOPSIS
    GUI wizard for safe git commits with Conventional Commits message.

.DESCRIPTION
    Shows modified/untracked files as a checklist, lets you compose a
    Conventional Commits message via dropdowns + fields, runs the existing
    04_tools/GitPush.ps1 (which gates on format/lint/typecheck/test).

    Double-click GitPush.cmd to launch. Pattern: tools-gui/README.md.
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
$cliPush = Join-Path $projectRoot '04_tools\GitPush.ps1'

Set-Location $projectRoot

# Check git repo
if (-not (Test-Path (Join-Path $projectRoot '.git'))) {
    [System.Windows.Forms.MessageBox]::Show(
        "Not a git repository:`n$projectRoot",
        'GitPush', 'OK', 'Error') | Out-Null
    exit 1
}

# Get changed files
$gitStatus = & git status --porcelain 2>&1
if ($LASTEXITCODE -ne 0) {
    [System.Windows.Forms.MessageBox]::Show("git status failed: $gitStatus", 'GitPush', 'OK', 'Error') | Out-Null
    exit 1
}
$changedFiles = @()
foreach ($line in $gitStatus) {
    if ($line.Length -ge 3) {
        $code = $line.Substring(0, 2)
        $path = $line.Substring(3).Trim('"')
        $changedFiles += [pscustomobject]@{ Status = $code.Trim(); Path = $path }
    }
}
if ($changedFiles.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show('Nothing to commit (working tree clean).', 'GitPush', 'OK', 'Information') | Out-Null
    exit 0
}

$branch = (& git rev-parse --abbrev-ref HEAD 2>&1).Trim()

# ---- Form ------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "GitPush - branch: $branch"
$form.Size = New-Object System.Drawing.Size(720, 700)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = 'Commit + push'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblBranch = New-Object System.Windows.Forms.Label
$lblBranch.Text = "Branch: $branch    Changed: $($changedFiles.Count) files"
$lblBranch.ForeColor = [System.Drawing.Color]::Gray
$lblBranch.Location = New-Object System.Drawing.Point(20, 45)
$lblBranch.AutoSize = $true

# Conventional Commits builder
$lblType = New-Object System.Windows.Forms.Label
$lblType.Text = 'Type'
$lblType.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblType.Location = New-Object System.Drawing.Point(20, 80)
$lblType.AutoSize = $true

$cmbType = New-Object System.Windows.Forms.ComboBox
$cmbType.Location = New-Object System.Drawing.Point(20, 100)
$cmbType.Size = New-Object System.Drawing.Size(120, 25)
$cmbType.DropDownStyle = 'DropDownList'
@('feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'build', 'ci', 'chore', 'revert') | ForEach-Object { [void]$cmbType.Items.Add($_) }
$cmbType.SelectedIndex = 0

$lblScope = New-Object System.Windows.Forms.Label
$lblScope.Text = 'Scope (optional)'
$lblScope.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblScope.Location = New-Object System.Drawing.Point(160, 80)
$lblScope.AutoSize = $true

$txtScope = New-Object System.Windows.Forms.TextBox
$txtScope.Location = New-Object System.Drawing.Point(160, 100)
$txtScope.Size = New-Object System.Drawing.Size(180, 25)

$lblSubject = New-Object System.Windows.Forms.Label
$lblSubject.Text = 'Subject (imperative)'
$lblSubject.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblSubject.Location = New-Object System.Drawing.Point(360, 80)
$lblSubject.AutoSize = $true

$txtSubject = New-Object System.Windows.Forms.TextBox
$txtSubject.Location = New-Object System.Drawing.Point(360, 100)
$txtSubject.Size = New-Object System.Drawing.Size(330, 25)

# Body
$lblBody = New-Object System.Windows.Forms.Label
$lblBody.Text = 'Body (optional)'
$lblBody.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblBody.Location = New-Object System.Drawing.Point(20, 140)
$lblBody.AutoSize = $true

$txtBody = New-Object System.Windows.Forms.TextBox
$txtBody.Location = New-Object System.Drawing.Point(20, 160)
$txtBody.Size = New-Object System.Drawing.Size(670, 80)
$txtBody.Multiline = $true
$txtBody.ScrollBars = 'Vertical'

# Preview
$lblPreview = New-Object System.Windows.Forms.Label
$lblPreview.Text = 'Message preview'
$lblPreview.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblPreview.Location = New-Object System.Drawing.Point(20, 250)
$lblPreview.AutoSize = $true

$txtPreview = New-Object System.Windows.Forms.TextBox
$txtPreview.Location = New-Object System.Drawing.Point(20, 270)
$txtPreview.Size = New-Object System.Drawing.Size(670, 60)
$txtPreview.Multiline = $true
$txtPreview.ReadOnly = $true
$txtPreview.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
$txtPreview.Font = New-Object System.Drawing.Font('Consolas', 9)

$updatePreview = {
    $t = $cmbType.SelectedItem
    $s = if ($txtScope.Text) { "($($txtScope.Text))" } else { '' }
    $line1 = "$t$s`: $($txtSubject.Text)"
    $msg = $line1
    if ($txtBody.Text) { $msg += "`r`n`r`n$($txtBody.Text)" }
    $txtPreview.Text = $msg
}.GetNewClosure()

$cmbType.Add_SelectedIndexChanged($updatePreview)
$txtScope.Add_TextChanged($updatePreview)
$txtSubject.Add_TextChanged($updatePreview)
$txtBody.Add_TextChanged($updatePreview)

# Files checklist
$lblFiles = New-Object System.Windows.Forms.Label
$lblFiles.Text = "Files to stage ($($changedFiles.Count))"
$lblFiles.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblFiles.Location = New-Object System.Drawing.Point(20, 345)
$lblFiles.AutoSize = $true

$btnAll = New-Object System.Windows.Forms.Button
$btnAll.Text = 'All'
$btnAll.Location = New-Object System.Drawing.Point(580, 343)
$btnAll.Size = New-Object System.Drawing.Size(50, 24)
$btnAll.FlatStyle = 'System'

$btnNone = New-Object System.Windows.Forms.Button
$btnNone.Text = 'None'
$btnNone.Location = New-Object System.Drawing.Point(640, 343)
$btnNone.Size = New-Object System.Drawing.Size(50, 24)
$btnNone.FlatStyle = 'System'

$clbFiles = New-Object System.Windows.Forms.CheckedListBox
$clbFiles.Location = New-Object System.Drawing.Point(20, 370)
$clbFiles.Size = New-Object System.Drawing.Size(670, 160)
$clbFiles.CheckOnClick = $true
$clbFiles.Font = New-Object System.Drawing.Font('Consolas', 9)
foreach ($f in $changedFiles) {
    $tag = switch -Regex ($f.Status) {
        '\?\?' { '[new]' }
        'M'    { '[mod]' }
        'D'    { '[del]' }
        'A'    { '[add]' }
        'R'    { '[ren]' }
        default { "[$($f.Status)]" }
    }
    [void]$clbFiles.Items.Add("$tag $($f.Path)", $true)
}

$btnAll.Add_Click({ for ($i = 0; $i -lt $clbFiles.Items.Count; $i++) { $clbFiles.SetItemChecked($i, $true) } })
$btnNone.Add_Click({ for ($i = 0; $i -lt $clbFiles.Items.Count; $i++) { $clbFiles.SetItemChecked($i, $false) } })

# Options
$chkSkipTest = New-Object System.Windows.Forms.CheckBox
$chkSkipTest.Text = 'Skip test step in pre-commit gate'
$chkSkipTest.Location = New-Object System.Drawing.Point(20, 545)
$chkSkipTest.AutoSize = $true

$chkDryRun = New-Object System.Windows.Forms.CheckBox
$chkDryRun.Text = 'Dry-run (show what would happen)'
$chkDryRun.Location = New-Object System.Drawing.Point(280, 545)
$chkDryRun.AutoSize = $true

# Status + buttons
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = ''
$lblStatus.Location = New-Object System.Drawing.Point(20, 580)
$lblStatus.Size = New-Object System.Drawing.Size(670, 20)

$btnPush = New-Object System.Windows.Forms.Button
$btnPush.Text = 'Commit + Push'
$btnPush.Location = New-Object System.Drawing.Point(20, 610)
$btnPush.Size = New-Object System.Drawing.Size(160, 38)
$btnPush.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnPush.ForeColor = [System.Drawing.Color]::White
$btnPush.FlatStyle = 'Flat'
$btnPush.FlatAppearance.BorderSize = 0
$btnPush.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Cancel'
$btnCancel.Location = New-Object System.Drawing.Point(570, 610)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnPush.Add_Click({
    if (-not $txtSubject.Text.Trim()) {
        [System.Windows.Forms.MessageBox]::Show('Subject is required.', 'Validation', 'OK', 'Warning') | Out-Null
        $txtSubject.Focus(); return
    }
    $picked = @()
    for ($i = 0; $i -lt $clbFiles.Items.Count; $i++) {
        if ($clbFiles.GetItemChecked($i)) {
            $picked += $changedFiles[$i].Path
        }
    }
    if ($picked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('Select at least one file to stage.', 'Validation', 'OK', 'Warning') | Out-Null
        return
    }

    $btnPush.Enabled = $false
    $btnCancel.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $lblStatus.Text = "Running pre-commit gate + commit + push ..."
    [System.Windows.Forms.Application]::DoEvents()

    $msg = $txtPreview.Text
    $args = @('-Message', $msg, '-Files') + $picked
    if ($chkSkipTest.Checked) { $args += '-NoTest' }
    if ($chkDryRun.Checked)   { $args += '-DryRun' }

    try {
        if (-not (Test-Path $cliPush)) { throw "04_tools/GitPush.ps1 not found at $cliPush" }
        $output = & $cliPush @args *>&1 | Out-String
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 0)
        $lblStatus.Text = "OK - commit + push complete"

        $dlgMsg = if ($chkDryRun.Checked) {
            "Dry-run output:`r`n`r`n$(($output -split "`n" | Select-Object -Last 25) -join "`r`n")"
        } else {
            "Pushed.`r`n`r`nOutput tail:`r`n$(($output -split "`n" | Select-Object -Last 15) -join "`r`n")"
        }
        [System.Windows.Forms.MessageBox]::Show($dlgMsg, 'GitPush', 'OK', 'Information') | Out-Null
        $form.Close()
    } catch {
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(192, 0, 0)
        $lblStatus.Text = "FAILED - see message"
        [System.Windows.Forms.MessageBox]::Show(
            "GitPush failed:`n`n$_`n`nOutput tail:`n$(($output -split "`n" | Select-Object -Last 10) -join "`n")",
            'Error', 'OK', 'Error') | Out-Null
        $btnPush.Enabled = $true
        $btnCancel.Enabled = $true
    } finally {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
})

$form.Controls.AddRange(@(
    $lblTitle, $lblBranch,
    $lblType, $cmbType,
    $lblScope, $txtScope,
    $lblSubject, $txtSubject,
    $lblBody, $txtBody,
    $lblPreview, $txtPreview,
    $lblFiles, $btnAll, $btnNone, $clbFiles,
    $chkSkipTest, $chkDryRun,
    $lblStatus, $btnPush, $btnCancel
))

& $updatePreview
[void]$form.ShowDialog()
$form.Dispose()

#Requires -Version 5.1
<#
.SYNOPSIS
    GUI to switch between lifecycle folder naming schemes.

.DESCRIPTION
    Real Zestraxz projects use different numbered-folder schemes per project
    type. This GUI lets you pick one and creates the empty folder skeleton.

    Schemes observed:
    - default     01_setup / 02_active / 03_history / 04_tools / 05_archive
    - workflow    00_WORKFLOW_DOCS / 01_ACTIVE_SETUP / 02_VALIDATION_TOOLS / 03_RESEARCH_SEQUENCE / 99_ARCHIVE
    - operations  00_README / 01_diagnostic / 02_cleanup / 03_optimize / 04_organize / 05_maintenance / 06_tooling
    - trading     .cTrader/ / auto-trade_vps/ / cBot Webhook Connector/ / docs/ / zz_archive/
    - simple      docs/ / src/ / tools/ / zz_archive/   (no numbering)

    Double-click Configure-Lifecycle.cmd to launch.
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

$schemes = @{
    'default'    = @('01_setup', '02_active', '03_history', '04_tools', '05_archive')
    'workflow'   = @('00_WORKFLOW_DOCS', '01_ACTIVE_SETUP', '02_VALIDATION_TOOLS', '03_RESEARCH_SEQUENCE', '99_ARCHIVE')
    'operations' = @('00_README', '01_diagnostic', '02_cleanup', '03_optimize', '04_organize', '05_maintenance', '06_tooling')
    'trading'    = @('docs', 'tools', 'research', 'zz_archive')
    'simple'     = @('docs', 'src', 'tools', 'archive')
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Configure Lifecycle - pick a numbered folder scheme'
$form.Size = New-Object System.Drawing.Size(700, 580)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = 'Configure Lifecycle'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Creates empty folders matching the chosen scheme at project root. Existing folders are kept; missing ones are created. Nothing is deleted."
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 48)
$lblSub.Size = New-Object System.Drawing.Size(640, 30)

# Scheme picker
$lblScheme = New-Object System.Windows.Forms.Label
$lblScheme.Text = 'Scheme'
$lblScheme.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblScheme.Location = New-Object System.Drawing.Point(20, 90)
$lblScheme.AutoSize = $true

$cmbScheme = New-Object System.Windows.Forms.ComboBox
$cmbScheme.Location = New-Object System.Drawing.Point(20, 110)
$cmbScheme.Size = New-Object System.Drawing.Size(240, 25)
$cmbScheme.DropDownStyle = 'DropDownList'
foreach ($k in $schemes.Keys | Sort-Object) { [void]$cmbScheme.Items.Add($k) }
$cmbScheme.SelectedItem = 'default'

# Preview
$lblPreview = New-Object System.Windows.Forms.Label
$lblPreview.Text = 'Preview'
$lblPreview.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblPreview.Location = New-Object System.Drawing.Point(20, 150)
$lblPreview.AutoSize = $true

$txtPreview = New-Object System.Windows.Forms.TextBox
$txtPreview.Location = New-Object System.Drawing.Point(20, 170)
$txtPreview.Size = New-Object System.Drawing.Size(640, 200)
$txtPreview.Multiline = $true
$txtPreview.ReadOnly = $true
$txtPreview.Font = New-Object System.Drawing.Font('Consolas', 9)
$txtPreview.ScrollBars = 'Vertical'
$txtPreview.BackColor = [System.Drawing.Color]::White

$update = {
    $name = $cmbScheme.SelectedItem
    $folders = $schemes[$name]
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("Scheme: $name")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Folders to ensure (creates if missing):")
    foreach ($f in $folders) {
        $exists = if (Test-Path (Join-Path $projectRoot $f)) { ' [exists]' } else { ' [will create]' }
        [void]$sb.AppendLine("  $f$exists")
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Notes:")
    switch ($name) {
        'default'    { [void]$sb.AppendLine("  Recommended for general use. Matches template's Principle 1.") }
        'workflow'   { [void]$sb.AppendLine("  For research / strategy / TV-Strategy style projects. Notice 99_ARCHIVE not 05_.") }
        'operations' { [void]$sb.AppendLine("  For ops scripts / system maintenance / PC-CleanUp style projects.") }
        'trading'    { [void]$sb.AppendLine("  For trading bots. Hidden dotfolder .cTrader/ for platform configs. zz_archive lowercase + zz_ prefix sorts last.") }
        'simple'     { [void]$sb.AppendLine("  No numbering. For tiny projects (under ~20 files). Flat is fine.") }
    }
    $txtPreview.Text = $sb.ToString()
}.GetNewClosure()
$cmbScheme.Add_SelectedIndexChanged($update)

$chkREADME = New-Object System.Windows.Forms.CheckBox
$chkREADME.Text = 'Add a README.md inside each created folder explaining its purpose'
$chkREADME.Location = New-Object System.Drawing.Point(20, 390)
$chkREADME.AutoSize = $true
$chkREADME.Checked = $true

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = ''
$lblStatus.Location = New-Object System.Drawing.Point(20, 430)
$lblStatus.Size = New-Object System.Drawing.Size(640, 50)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = 'Apply Scheme'
$btnApply.Location = New-Object System.Drawing.Point(20, 490)
$btnApply.Size = New-Object System.Drawing.Size(160, 38)
$btnApply.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnApply.ForeColor = [System.Drawing.Color]::White
$btnApply.FlatStyle = 'Flat'
$btnApply.FlatAppearance.BorderSize = 0
$btnApply.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Close'
$btnCancel.Location = New-Object System.Drawing.Point(540, 490)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnApply.Add_Click({
    $name = $cmbScheme.SelectedItem
    $folders = $schemes[$name]
    $created = 0
    $skipped = 0
    foreach ($f in $folders) {
        $p = Join-Path $projectRoot $f
        if (Test-Path $p) {
            $skipped++
        } else {
            New-Item -ItemType Directory -Path $p -Force | Out-Null
            if ($chkREADME.Checked) {
                $readmePath = Join-Path $p 'README.md'
                $stub = "# $f`r`n`r`n_(Auto-created by tools-gui/Configure-Lifecycle on $(Get-Date -Format 'yyyy-MM-dd'). Replace with actual purpose description.)_`r`n"
                [System.IO.File]::WriteAllText($readmePath, $stub, [System.Text.UTF8Encoding]::new($false))
            }
            $created++
        }
    }
    $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 0)
    $lblStatus.Text = "OK: $created folder(s) created, $skipped existing skipped. Scheme: $name"
    & $update  # refresh preview
})

$form.Controls.AddRange(@(
    $lblTitle, $lblSub,
    $lblScheme, $cmbScheme,
    $lblPreview, $txtPreview,
    $chkREADME, $lblStatus,
    $btnApply, $btnCancel
))

& $update  # initial preview
[void]$form.ShowDialog()
$form.Dispose()

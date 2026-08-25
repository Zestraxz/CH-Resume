#Requires -Version 5.1
<#
.SYNOPSIS
    GUI wizard for filling .env from .env.example.

.DESCRIPTION
    Reads .env.example, opens a scrollable form with one field per variable,
    writes .env. Auto-generates random values for secret-looking variables
    on a single click.

    Double-click Setup-Env.cmd to launch. Pattern: tools-gui/README.md.
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

# tools-gui sits one level under project root
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$envExample = Join-Path $projectRoot '.env.example'
$envFile    = Join-Path $projectRoot '.env'

if (-not (Test-Path $envExample)) {
    [System.Windows.Forms.MessageBox]::Show(
        "No .env.example found at:`n$envExample`n`nNothing to set up.",
        'Setup-Env', 'OK', 'Warning') | Out-Null
    exit 0
}

# ---- Parse .env.example ----------------------------------------------------
$entries = @()
foreach ($line in (Get-Content $envExample)) {
    $trimmed = $line.Trim()
    if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }
    $idx = $line.IndexOf('=')
    if ($idx -lt 1) { continue }
    $key = $line.Substring(0, $idx).Trim()
    $val = if ($idx -lt $line.Length - 1) { $line.Substring($idx + 1) } else { '' }
    $entries += [pscustomobject]@{ Key = $key; Default = $val }
}

if ($entries.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show('.env.example has no KEY=VALUE entries to fill.', 'Setup-Env', 'OK', 'Information') | Out-Null
    exit 0
}

# ---- Helper: random secret -------------------------------------------------
function New-Secret { param([int]$Bytes = 32)
    $b = New-Object byte[] $Bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
    [Convert]::ToBase64String($b).TrimEnd('=')
}

# ---- Form ------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Setup-Env - fill .env from .env.example'
$form.Size = New-Object System.Drawing.Size(720, 640)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Setup-Env - $($entries.Count) variables"
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Target: $envFile" + $(if (Test-Path $envFile) { '  [will overwrite]' } else { '' })
$lblSub.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
$lblSub.ForeColor = if (Test-Path $envFile) { [System.Drawing.Color]::FromArgb(192, 64, 0) } else { [System.Drawing.Color]::Gray }
$lblSub.Location = New-Object System.Drawing.Point(20, 45)
$lblSub.AutoSize = $true

# Scrollable panel
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(20, 75)
$panel.Size = New-Object System.Drawing.Size(670, 480)
$panel.AutoScroll = $true
$panel.BorderStyle = 'FixedSingle'
$panel.BackColor = [System.Drawing.Color]::White

$textBoxes = @{}
$y = 10
foreach ($e in $entries) {
    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $e.Key
    $lbl.Font = New-Object System.Drawing.Font('Consolas', 9)
    $lbl.Location = New-Object System.Drawing.Point(10, ($y + 4))
    $lbl.Size = New-Object System.Drawing.Size(260, 22)

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.Location = New-Object System.Drawing.Point(280, $y)
    $txt.Size = New-Object System.Drawing.Size(290, 25)
    $txt.Text = $e.Default

    # Smart pre-fill for secret-looking keys
    $isSecret = $e.Key -match '(?i)(SECRET|TOKEN|PASSWORD|KEY|API_KEY)$' -and ($e.Default -match 'change-me' -or [string]::IsNullOrWhiteSpace($e.Default))
    if ($isSecret) {
        $txt.Text = New-Secret
        $txt.BackColor = [System.Drawing.Color]::FromArgb(232, 245, 233)
    }

    $btnGen = New-Object System.Windows.Forms.Button
    $btnGen.Text = 'Gen'
    $btnGen.Location = New-Object System.Drawing.Point(580, ($y - 1))
    $btnGen.Size = New-Object System.Drawing.Size(50, 27)
    $btnGen.FlatStyle = 'System'
    $btnGen.Tag = $txt
    $btnGen.Add_Click({ $this.Tag.Text = (New-Secret); $this.Tag.BackColor = [System.Drawing.Color]::FromArgb(232, 245, 233) })

    $panel.Controls.AddRange(@($lbl, $txt, $btnGen))
    $textBoxes[$e.Key] = $txt
    $y += 32
}

# Buttons
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text = "Gen = generate random secret. Empty values stay empty in .env."
$lblHint.ForeColor = [System.Drawing.Color]::Gray
$lblHint.Location = New-Object System.Drawing.Point(20, 565)
$lblHint.AutoSize = $true

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = 'Save .env'
$btnSave.Location = New-Object System.Drawing.Point(20, 590)
$btnSave.Size = New-Object System.Drawing.Size(140, 35)
$btnSave.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnSave.ForeColor = [System.Drawing.Color]::White
$btnSave.FlatStyle = 'Flat'
$btnSave.FlatAppearance.BorderSize = 0

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Cancel'
$btnCancel.Location = New-Object System.Drawing.Point(570, 590)
$btnCancel.Size = New-Object System.Drawing.Size(120, 35)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnSave.Add_Click({
    if (Test-Path $envFile) {
        $bak = "$envFile.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $envFile $bak -Force
    }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('# Generated by tools-gui/Setup-Env.cmd on ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
    [void]$sb.AppendLine('# Re-run Setup-Env.cmd to update; existing .env backed up to .env.bak.<timestamp>')
    [void]$sb.AppendLine('')
    foreach ($e in $entries) {
        [void]$sb.AppendLine("$($e.Key)=$($textBoxes[$e.Key].Text)")
    }
    [System.IO.File]::WriteAllText($envFile, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))

    [System.Windows.Forms.MessageBox]::Show(
        ".env saved.`n`n$envFile",
        'Setup-Env - Saved', 'OK', 'Information') | Out-Null
    $form.Close()
})

$form.Controls.AddRange(@($lblTitle, $lblSub, $panel, $lblHint, $btnSave, $btnCancel))
$form.AcceptButton = $btnSave
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

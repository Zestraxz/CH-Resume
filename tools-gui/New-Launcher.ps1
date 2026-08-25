#Requires -Version 5.1
<#
.SYNOPSIS
    GUI wizard to scaffold a new role-specific .cmd launcher at project root.

.DESCRIPTION
    Real CH-* projects ship 3-6 role-specific .cmd launchers (Activate_Trading,
    Run_Live_Readiness_Check, Start_Paper_Trading, RUN-WEEKLY, etc.).
    This wizard creates a new <Name>.cmd at project root, optionally with a
    matching <Name>.ps1 body in scripts/ for non-trivial logic.

    Double-click New-Launcher.cmd to launch.
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

$form = New-Object System.Windows.Forms.Form
$form.Text = 'New Launcher - role-specific .cmd at project root'
$form.Size = New-Object System.Drawing.Size(660, 520)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = 'New Launcher'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 13)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Creates <Name>.cmd at project root. Optionally pairs with a <Name>.ps1 in scripts/ for non-trivial logic."
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 45)
$lblSub.AutoSize = $true

# Name
$lblName = New-Object System.Windows.Forms.Label
$lblName.Text = 'Launcher Name *'
$lblName.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblName.Location = New-Object System.Drawing.Point(20, 80)
$lblName.AutoSize = $true

$txtName = New-Object System.Windows.Forms.TextBox
$txtName.Location = New-Object System.Drawing.Point(20, 100)
$txtName.Size = New-Object System.Drawing.Size(600, 25)

$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Text = 'e.g. Activate_Trading, Run_Daily_Reports, Start_Paper_Trading, RUN-WEEKLY'
$lblHint.ForeColor = [System.Drawing.Color]::Gray
$lblHint.Location = New-Object System.Drawing.Point(20, 127)
$lblHint.AutoSize = $true

# Mode
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = 'Mode'
$lblMode.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblMode.Location = New-Object System.Drawing.Point(20, 160)
$lblMode.AutoSize = $true

$rdoSimple = New-Object System.Windows.Forms.RadioButton
$rdoSimple.Text = 'Simple - .cmd only, runs a single command inline'
$rdoSimple.Location = New-Object System.Drawing.Point(40, 180)
$rdoSimple.AutoSize = $true
$rdoSimple.Checked = $true

$rdoPaired = New-Object System.Windows.Forms.RadioButton
$rdoPaired.Text = 'Paired - .cmd wrapper + scripts/<Name>.ps1 body (recommended for logic > 1 line)'
$rdoPaired.Location = New-Object System.Drawing.Point(40, 205)
$rdoPaired.AutoSize = $true

# Command / description
$lblCmd = New-Object System.Windows.Forms.Label
$lblCmd.Text = 'Command (simple) OR description (paired)'
$lblCmd.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblCmd.Location = New-Object System.Drawing.Point(20, 240)
$lblCmd.AutoSize = $true

$txtCmd = New-Object System.Windows.Forms.TextBox
$txtCmd.Location = New-Object System.Drawing.Point(20, 260)
$txtCmd.Size = New-Object System.Drawing.Size(600, 80)
$txtCmd.Multiline = $true
$txtCmd.ScrollBars = 'Vertical'
$txtCmd.Font = New-Object System.Drawing.Font('Consolas', 9)
$txtCmd.Text = "pnpm test"

$lblWindowMode = New-Object System.Windows.Forms.Label
$lblWindowMode.Text = 'Window'
$lblWindowMode.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblWindowMode.Location = New-Object System.Drawing.Point(20, 360)
$lblWindowMode.AutoSize = $true

$cmbWindow = New-Object System.Windows.Forms.ComboBox
$cmbWindow.Location = New-Object System.Drawing.Point(20, 380)
$cmbWindow.Size = New-Object System.Drawing.Size(200, 25)
$cmbWindow.DropDownStyle = 'DropDownList'
@('visible (default)', 'hidden (background)') | ForEach-Object { [void]$cmbWindow.Items.Add($_) }
$cmbWindow.SelectedIndex = 0

$chkPauseOnError = New-Object System.Windows.Forms.CheckBox
$chkPauseOnError.Text = 'Pause on error (recommended for double-click users)'
$chkPauseOnError.Location = New-Object System.Drawing.Point(240, 384)
$chkPauseOnError.AutoSize = $true
$chkPauseOnError.Checked = $true

$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = 'Create Launcher'
$btnCreate.Location = New-Object System.Drawing.Point(20, 430)
$btnCreate.Size = New-Object System.Drawing.Size(160, 38)
$btnCreate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnCreate.ForeColor = [System.Drawing.Color]::White
$btnCreate.FlatStyle = 'Flat'
$btnCreate.FlatAppearance.BorderSize = 0
$btnCreate.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Cancel'
$btnCancel.Location = New-Object System.Drawing.Point(500, 430)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnCreate.Add_Click({
    $name = $txtName.Text.Trim()
    if (-not $name) {
        [System.Windows.Forms.MessageBox]::Show('Launcher Name is required.', 'Validation', 'OK', 'Warning') | Out-Null
        $txtName.Focus(); return
    }
    if ($name -notmatch '^[A-Za-z][A-Za-z0-9_-]*$') {
        [System.Windows.Forms.MessageBox]::Show("Name must start with a letter and contain only letters, digits, underscores, or hyphens.`n`nGot: $name", 'Validation', 'OK', 'Warning') | Out-Null
        return
    }

    $cmdPath = Join-Path $projectRoot "$name.cmd"
    if (Test-Path $cmdPath) {
        [System.Windows.Forms.MessageBox]::Show("File already exists:`n$cmdPath", 'Error', 'OK', 'Error') | Out-Null
        return
    }

    $hidden = $cmbWindow.SelectedIndex -eq 1
    $pauseOnError = $chkPauseOnError.Checked

    if ($rdoSimple.Checked) {
        # Simple mode: .cmd only runs the command directly
        $cmdContent = "@echo off`r`nsetlocal`r`nREM Created by tools-gui/New-Launcher on $(Get-Date -Format 'yyyy-MM-dd')`r`n`r`n"
        if ($hidden) {
            $cmdContent += "start /b cmd /c `"$($txtCmd.Text.Trim())`"`r`n"
        } else {
            $cmdContent += "$($txtCmd.Text.Trim())`r`n"
        }
        $cmdContent += "set `"EXITCODE=%ERRORLEVEL%`"`r`n"
        if ($pauseOnError) {
            $cmdContent += "if not `"%EXITCODE%`"==`"0`" (`r`n    echo Exit code: %EXITCODE%`r`n    pause >nul`r`n)`r`n"
        }
        $cmdContent += "endlocal & exit /b %EXITCODE%`r`n"
        [System.IO.File]::WriteAllText($cmdPath, $cmdContent, [System.Text.UTF8Encoding]::new($false))
    } else {
        # Paired mode: .cmd wrapper + .ps1 in scripts/
        $scriptsDir = Join-Path $projectRoot 'scripts'
        if (-not (Test-Path $scriptsDir)) { New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null }
        $ps1Path = Join-Path $scriptsDir "$name.ps1"

        $cmdContent = "@echo off`r`nsetlocal`r`nREM Created by tools-gui/New-Launcher on $(Get-Date -Format 'yyyy-MM-dd')`r`n`r`n"
        $hiddenFlag = if ($hidden) { ' -WindowStyle Hidden' } else { '' }
        $cmdContent += "powershell -NoProfile -ExecutionPolicy Bypass$hiddenFlag -File `"%~dp0scripts\$name.ps1`"`r`n"
        $cmdContent += "set `"EXITCODE=%ERRORLEVEL%`"`r`n"
        if ($pauseOnError) {
            $cmdContent += "if not `"%EXITCODE%`"==`"0`" (`r`n    echo Exit code: %EXITCODE%. Check above for errors.`r`n    pause >nul`r`n)`r`n"
        }
        $cmdContent += "endlocal & exit /b %EXITCODE%`r`n"
        [System.IO.File]::WriteAllText($cmdPath, $cmdContent, [System.Text.UTF8Encoding]::new($false))

        $ps1Body = $txtCmd.Text.Trim()
        $ps1Content = @"
#Requires -Version 5.1
<#
.SYNOPSIS
    $name - $ps1Body

.DESCRIPTION
    Created by tools-gui/New-Launcher on $(Get-Date -Format 'yyyy-MM-dd').
    Edit this file for non-trivial logic. The .cmd wrapper at project root
    is just a double-click target.
#>

`$ErrorActionPreference = 'Stop'
`$ProjectRoot = Split-Path -Parent `$PSScriptRoot
Set-Location `$ProjectRoot

Write-Host "==> Running $name" -ForegroundColor Cyan

# TODO: implement
Write-Host "$ps1Body" -ForegroundColor Yellow

Write-Host "OK: $name complete" -ForegroundColor Green
"@
        [System.IO.File]::WriteAllText($ps1Path, $ps1Content, [System.Text.UTF8Encoding]::new($false))
    }

    [System.Windows.Forms.MessageBox]::Show(
        "Created:`n$cmdPath$( if ($rdoPaired.Checked) { "`n$(Join-Path $projectRoot "scripts\$name.ps1")" } )`n`nDouble-click the .cmd to test.",
        'New-Launcher - Created', 'OK', 'Information') | Out-Null
    $form.Close()
})

$form.Controls.AddRange(@(
    $lblTitle, $lblSub,
    $lblName, $txtName, $lblHint,
    $lblMode, $rdoSimple, $rdoPaired,
    $lblCmd, $txtCmd,
    $lblWindowMode, $cmbWindow, $chkPauseOnError,
    $btnCreate, $btnCancel
))
$form.AcceptButton = $btnCreate
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

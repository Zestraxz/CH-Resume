#Requires -Version 5.1
<#
.SYNOPSIS
    GUI to create a new Architecture Decision Record.

.DESCRIPTION
    Scans docs/04-quality/adr/ for the highest existing ADR number, opens
    a form for title + status + supersedes, then creates a new file
    auto-numbered (NNNN-title-slug.md) from the 0001 template.

    Double-click New-ADR.cmd to launch. Pattern: tools-gui/README.md.
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
$adrDir = Join-Path $projectRoot 'docs\04-quality\adr'

if (-not (Test-Path $adrDir)) {
    [System.Windows.Forms.MessageBox]::Show("ADR directory not found:`n$adrDir", 'New-ADR', 'OK', 'Error') | Out-Null
    exit 1
}

# Scan existing ADRs
$existing = Get-ChildItem $adrDir -Filter '*.md' -File | Where-Object { $_.Name -match '^(\d{4})-' } |
    ForEach-Object {
        [pscustomobject]@{
            Number = [int]$matches[1]
            Title  = ($_.BaseName -replace '^\d{4}-', '')
            Path   = $_.FullName
        }
    } | Sort-Object Number

$nextNumber = if ($existing) { ($existing | Select-Object -Last 1).Number + 1 } else { 1 }
$templatePath = ($existing | Where-Object { $_.Number -eq 1 } | Select-Object -First 1).Path
if (-not $templatePath) { $templatePath = ($existing | Select-Object -First 1).Path }

# ---- Form ------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "New ADR - next number: $('{0:D4}' -f $nextNumber)"
$form.Size = New-Object System.Drawing.Size(620, 440)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "ADR-$('{0:D4}' -f $nextNumber)"
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Existing ADRs: $($existing.Count)  |  Output: docs/04-quality/adr/$('{0:D4}' -f $nextNumber)-<slug>.md"
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 50)
$lblSub.AutoSize = $true

# Title
$lblTit = New-Object System.Windows.Forms.Label
$lblTit.Text = 'Decision Title *'
$lblTit.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblTit.Location = New-Object System.Drawing.Point(20, 90)
$lblTit.AutoSize = $true

$txtTitle = New-Object System.Windows.Forms.TextBox
$txtTitle.Location = New-Object System.Drawing.Point(20, 110)
$txtTitle.Size = New-Object System.Drawing.Size(560, 25)

$lblSlug = New-Object System.Windows.Forms.Label
$lblSlug.Text = 'slug preview:'
$lblSlug.ForeColor = [System.Drawing.Color]::Gray
$lblSlug.Location = New-Object System.Drawing.Point(20, 138)
$lblSlug.AutoSize = $true

# Status
$lblStat = New-Object System.Windows.Forms.Label
$lblStat.Text = 'Status'
$lblStat.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblStat.Location = New-Object System.Drawing.Point(20, 170)
$lblStat.AutoSize = $true

$cmbStatus = New-Object System.Windows.Forms.ComboBox
$cmbStatus.Location = New-Object System.Drawing.Point(20, 190)
$cmbStatus.Size = New-Object System.Drawing.Size(200, 25)
$cmbStatus.DropDownStyle = 'DropDownList'
@('Proposed', 'Accepted', 'Rejected') | ForEach-Object { [void]$cmbStatus.Items.Add($_) }
$cmbStatus.SelectedIndex = 0

# Supersedes
$lblSup = New-Object System.Windows.Forms.Label
$lblSup.Text = 'Supersedes (optional)'
$lblSup.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblSup.Location = New-Object System.Drawing.Point(20, 230)
$lblSup.AutoSize = $true

$cmbSup = New-Object System.Windows.Forms.ComboBox
$cmbSup.Location = New-Object System.Drawing.Point(20, 250)
$cmbSup.Size = New-Object System.Drawing.Size(560, 25)
$cmbSup.DropDownStyle = 'DropDownList'
[void]$cmbSup.Items.Add('(none)')
foreach ($e in $existing) { [void]$cmbSup.Items.Add("ADR-$('{0:D4}' -f $e.Number) - $($e.Title)") }
$cmbSup.SelectedIndex = 0

# Open after create
$chkOpen = New-Object System.Windows.Forms.CheckBox
$chkOpen.Text = 'Open in editor after create'
$chkOpen.Location = New-Object System.Drawing.Point(20, 295)
$chkOpen.AutoSize = $true
$chkOpen.Checked = $true

# Update slug preview
$updateSlug = {
    $t = $txtTitle.Text
    $slug = ($t -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-').Trim('-').ToLower()
    if ($slug) {
        $lblSlug.Text = "Filename: $('{0:D4}' -f $nextNumber)-$slug.md"
        $lblSlug.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
    } else {
        $lblSlug.Text = 'Filename: (enter title)'
        $lblSlug.ForeColor = [System.Drawing.Color]::Gray
    }
}.GetNewClosure()
$txtTitle.Add_TextChanged($updateSlug)

# Buttons
$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = 'Create ADR'
$btnCreate.Location = New-Object System.Drawing.Point(20, 350)
$btnCreate.Size = New-Object System.Drawing.Size(160, 38)
$btnCreate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnCreate.ForeColor = [System.Drawing.Color]::White
$btnCreate.FlatStyle = 'Flat'
$btnCreate.FlatAppearance.BorderSize = 0
$btnCreate.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Cancel'
$btnCancel.Location = New-Object System.Drawing.Point(460, 350)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnCreate.Add_Click({
    $title = $txtTitle.Text.Trim()
    if (-not $title) {
        [System.Windows.Forms.MessageBox]::Show('Title is required.', 'Validation', 'OK', 'Warning') | Out-Null
        $txtTitle.Focus(); return
    }
    $slug = ($title -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-').Trim('-').ToLower()
    if (-not $slug) {
        [System.Windows.Forms.MessageBox]::Show('Title produced empty slug; use alphanumeric characters.', 'Validation', 'OK', 'Warning') | Out-Null
        return
    }

    $num = '{0:D4}' -f $nextNumber
    $newPath = Join-Path $adrDir "$num-$slug.md"
    if (Test-Path $newPath) {
        [System.Windows.Forms.MessageBox]::Show("File already exists:`n$newPath", 'Error', 'OK', 'Error') | Out-Null
        return
    }

    # Build body
    $supersedesLine = ''
    if ($cmbSup.SelectedIndex -gt 0) {
        $supersedesLine = "**Supersedes:** $($cmbSup.SelectedItem)`r`n"
    }

    $body = @"
# $num - $title

**Status:** $($cmbStatus.SelectedItem)
**Date:** $(Get-Date -Format 'yyyy-MM-dd')
**Deciders:** {{OWNER_OR_TEAM}}
$supersedesLine
---

## Context

What is the issue we are seeing that is motivating this decision or change?

## Decision

What is the change that we are proposing or doing?

## Consequences

### Positive
- ...

### Negative
- ...

### Neutral
- ...

## Alternatives considered

- ...

## References

- ...
"@

    [System.IO.File]::WriteAllText($newPath, $body, [System.Text.UTF8Encoding]::new($false))

    if ($chkOpen.Checked) {
        try { Invoke-Item $newPath } catch {}
    }

    [System.Windows.Forms.MessageBox]::Show(
        "Created:`n$newPath`n`nFill in Context / Decision / Consequences then commit.",
        'New-ADR - Created', 'OK', 'Information') | Out-Null
    $form.Close()
})

$form.Controls.AddRange(@(
    $lblTitle, $lblSub,
    $lblTit, $txtTitle, $lblSlug,
    $lblStat, $cmbStatus,
    $lblSup, $cmbSup,
    $chkOpen,
    $btnCreate, $btnCancel
))
$form.AcceptButton = $btnCreate
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

#Requires -Version 5.1
<#
.SYNOPSIS
    GUI to create a new RFC (Request for Comments) document.

.DESCRIPTION
    Scans rfcs/ for the highest existing RFC number, opens a form for
    title + related-to + author, then creates rfcs/active/NNNN-title-slug.md
    from rfcs/0000-template.md.

    Standard+ profile only. Double-click New-RFC.cmd to launch.
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
$rfcRoot = Join-Path $projectRoot 'rfcs'
$rfcActive = Join-Path $rfcRoot 'active'
$rfcTemplate = Join-Path $rfcRoot '0000-template.md'

if (-not (Test-Path $rfcRoot)) {
    [System.Windows.Forms.MessageBox]::Show(
        "rfcs/ directory not found:`n$rfcRoot`n`nRFC pattern requires standard+ profile.",
        'New-RFC', 'OK', 'Error') | Out-Null
    exit 1
}
if (-not (Test-Path $rfcActive)) { New-Item -ItemType Directory -Path $rfcActive | Out-Null }

# Scan existing RFCs across active/accepted/rejected
$allFiles = Get-ChildItem -Path $rfcRoot -Recurse -Filter '*.md' -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^(\d{4})-' -and $_.Name -ne '0000-template.md' }

$existing = $allFiles | ForEach-Object {
    [pscustomobject]@{
        Number = [int]([regex]::Match($_.Name, '^(\d{4})-').Groups[1].Value)
        Title  = ($_.BaseName -replace '^\d{4}-', '')
        Path   = $_.FullName
    }
} | Sort-Object Number

$nextNumber = if ($existing) { ($existing | Select-Object -Last 1).Number + 1 } else { 1 }

# ---- Form ------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "New RFC - next number: $('{0:D4}' -f $nextNumber)"
$form.Size = New-Object System.Drawing.Size(620, 430)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblHeader = New-Object System.Windows.Forms.Label
$lblHeader.Text = "RFC-$('{0:D4}' -f $nextNumber)"
$lblHeader.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
$lblHeader.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblHeader.Location = New-Object System.Drawing.Point(20, 15)
$lblHeader.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Existing RFCs: $($existing.Count)  |  Output: rfcs/active/$('{0:D4}' -f $nextNumber)-<slug>.md"
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 50)
$lblSub.AutoSize = $true

$lblTit = New-Object System.Windows.Forms.Label
$lblTit.Text = 'RFC Title *'
$lblTit.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblTit.Location = New-Object System.Drawing.Point(20, 90)
$lblTit.AutoSize = $true

$txtTitle = New-Object System.Windows.Forms.TextBox
$txtTitle.Location = New-Object System.Drawing.Point(20, 110)
$txtTitle.Size = New-Object System.Drawing.Size(560, 25)

$lblSlug = New-Object System.Windows.Forms.Label
$lblSlug.Text = 'Filename: (enter title)'
$lblSlug.ForeColor = [System.Drawing.Color]::Gray
$lblSlug.Location = New-Object System.Drawing.Point(20, 138)
$lblSlug.AutoSize = $true

$lblAuthor = New-Object System.Windows.Forms.Label
$lblAuthor.Text = 'Author'
$lblAuthor.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblAuthor.Location = New-Object System.Drawing.Point(20, 170)
$lblAuthor.AutoSize = $true

$txtAuthor = New-Object System.Windows.Forms.TextBox
$txtAuthor.Location = New-Object System.Drawing.Point(20, 190)
$txtAuthor.Size = New-Object System.Drawing.Size(300, 25)
$txtAuthor.Text = $env:USERNAME

$lblRel = New-Object System.Windows.Forms.Label
$lblRel.Text = 'Related-to (optional)'
$lblRel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblRel.Location = New-Object System.Drawing.Point(20, 230)
$lblRel.AutoSize = $true

$cmbRel = New-Object System.Windows.Forms.ComboBox
$cmbRel.Location = New-Object System.Drawing.Point(20, 250)
$cmbRel.Size = New-Object System.Drawing.Size(560, 25)
$cmbRel.DropDownStyle = 'DropDownList'
[void]$cmbRel.Items.Add('(none)')
foreach ($e in $existing) { [void]$cmbRel.Items.Add("RFC-$('{0:D4}' -f $e.Number) - $($e.Title)") }
$cmbRel.SelectedIndex = 0

$chkOpen = New-Object System.Windows.Forms.CheckBox
$chkOpen.Text = 'Open in editor after create'
$chkOpen.Location = New-Object System.Drawing.Point(20, 295)
$chkOpen.AutoSize = $true
$chkOpen.Checked = $true

$updateSlug = {
    $t = $txtTitle.Text
    $slug = ($t -replace '[^a-zA-Z0-9\s-]', '' -replace '\s+', '-').Trim('-').ToLower()
    if ($slug) {
        $lblSlug.Text = "Filename: active/$('{0:D4}' -f $nextNumber)-$slug.md"
        $lblSlug.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
    } else {
        $lblSlug.Text = 'Filename: (enter title)'
        $lblSlug.ForeColor = [System.Drawing.Color]::Gray
    }
}.GetNewClosure()
$txtTitle.Add_TextChanged($updateSlug)

$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = 'Create RFC'
$btnCreate.Location = New-Object System.Drawing.Point(20, 340)
$btnCreate.Size = New-Object System.Drawing.Size(160, 38)
$btnCreate.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnCreate.ForeColor = [System.Drawing.Color]::White
$btnCreate.FlatStyle = 'Flat'
$btnCreate.FlatAppearance.BorderSize = 0
$btnCreate.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Cancel'
$btnCancel.Location = New-Object System.Drawing.Point(460, 340)
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
        [System.Windows.Forms.MessageBox]::Show('Title produced empty slug.', 'Validation', 'OK', 'Warning') | Out-Null
        return
    }

    $num = '{0:D4}' -f $nextNumber
    $newPath = Join-Path $rfcActive "$num-$slug.md"
    if (Test-Path $newPath) {
        [System.Windows.Forms.MessageBox]::Show("File already exists:`n$newPath", 'Error', 'OK', 'Error') | Out-Null
        return
    }

    $relatedLine = if ($cmbRel.SelectedIndex -gt 0) { "- Related: $($cmbRel.SelectedItem)" } else { "- Related: (none)" }

    $body = @"
# RFC $num - $title

- **Author:** $($txtAuthor.Text)
- **Date:** $(Get-Date -Format 'yyyy-MM-dd')
- **Status:** Active
$relatedLine

---

## Summary

One paragraph. The 30-second pitch.

## Motivation

Why are we considering this? What pain does it solve?

## Detailed design

The meat. Diagrams, schemas, API shapes, migration plan.

## Alternatives considered

| Option | Pros | Cons | Why not |
|---|---|---|---|
| ... | ... | ... | ... |

## Drawbacks

What's bad about the proposed design?

## Adoption plan

Sequence of steps. Rollback plan.

## Open questions

- ...

## References

- ...
"@

    [System.IO.File]::WriteAllText($newPath, $body, [System.Text.UTF8Encoding]::new($false))

    if ($chkOpen.Checked) {
        try { Invoke-Item $newPath } catch {}
    }

    [System.Windows.Forms.MessageBox]::Show(
        "Created:`n$newPath`n`nWhen consensus reached: move to rfcs/accepted/ and create an ADR.",
        'New-RFC - Created', 'OK', 'Information') | Out-Null
    $form.Close()
})

$form.Controls.AddRange(@(
    $lblHeader, $lblSub,
    $lblTit, $txtTitle, $lblSlug,
    $lblAuthor, $txtAuthor,
    $lblRel, $cmbRel,
    $chkOpen,
    $btnCreate, $btnCancel
))
$form.AcceptButton = $btnCreate
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

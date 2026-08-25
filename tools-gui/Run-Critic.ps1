#Requires -Version 5.1
<#
.SYNOPSIS
    GUI to assemble a Critic Agent v2.0 prompt + current project context.

.DESCRIPTION
    Assembles the Critic Agent system prompt with the current state of your
    project (file tree summary, recent commits, key docs) and copies it to
    your clipboard. Then opens Claude.ai in your browser. You paste, get
    the critique, and save the response to 02_active/critic-report-<date>.md
    (or wherever).

    No API key required. No surprise costs. You control where the request
    runs (Claude.ai web, claude-code, your own API call, etc.).

    Double-click Run-Critic.cmd to launch.
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
Set-Location $projectRoot

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Run Critic Agent - assemble prompt + context'
$form.Size = New-Object System.Drawing.Size(680, 600)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 250)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = 'Critic Agent v2.0'
$lblTitle.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 14)
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Assembles the McKinsey-grade critic prompt + your project state. Copies to clipboard. Opens Claude.ai. You paste."
$lblSub.ForeColor = [System.Drawing.Color]::Gray
$lblSub.Location = New-Object System.Drawing.Point(20, 50)
$lblSub.Size = New-Object System.Drawing.Size(620, 30)

# Mode
$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Text = 'Evaluation Mode'
$lblMode.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblMode.Location = New-Object System.Drawing.Point(20, 95)
$lblMode.AutoSize = $true

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.Location = New-Object System.Drawing.Point(20, 115)
$cmbMode.Size = New-Object System.Drawing.Size(250, 25)
$cmbMode.DropDownStyle = 'DropDownList'
@('TECHNICAL (code/architecture)', 'STRATEGIC (plan/decision)', 'SYSTEMS (process/workflow)', 'ADVERSARIAL (red team)') | ForEach-Object { [void]$cmbMode.Items.Add($_) }
$cmbMode.SelectedIndex = 0

# Focus area
$lblFocus = New-Object System.Windows.Forms.Label
$lblFocus.Text = 'Focus area (what to critique)'
$lblFocus.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblFocus.Location = New-Object System.Drawing.Point(20, 155)
$lblFocus.AutoSize = $true

$txtFocus = New-Object System.Windows.Forms.TextBox
$txtFocus.Location = New-Object System.Drawing.Point(20, 175)
$txtFocus.Size = New-Object System.Drawing.Size(620, 25)
$txtFocus.Text = 'Full project structure + key docs (default)'

# Include checkboxes
$lblInclude = New-Object System.Windows.Forms.Label
$lblInclude.Text = 'Include in context'
$lblInclude.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblInclude.Location = New-Object System.Drawing.Point(20, 215)
$lblInclude.AutoSize = $true

$chkTree = New-Object System.Windows.Forms.CheckBox
$chkTree.Text = 'File tree (top 100 paths)'
$chkTree.Location = New-Object System.Drawing.Point(30, 240)
$chkTree.AutoSize = $true
$chkTree.Checked = $true

$chkReadme = New-Object System.Windows.Forms.CheckBox
$chkReadme.Text = 'README.md'
$chkReadme.Location = New-Object System.Drawing.Point(280, 240)
$chkReadme.AutoSize = $true
$chkReadme.Checked = $true

$chkAgents = New-Object System.Windows.Forms.CheckBox
$chkAgents.Text = 'AGENTS.md (canonical AI brief)'
$chkAgents.Location = New-Object System.Drawing.Point(30, 265)
$chkAgents.AutoSize = $true
$chkAgents.Checked = $true

$chkStatus = New-Object System.Windows.Forms.CheckBox
$chkStatus.Text = 'STATUS.md'
$chkStatus.Location = New-Object System.Drawing.Point(280, 265)
$chkStatus.AutoSize = $true
$chkStatus.Checked = $true

$chkCommits = New-Object System.Windows.Forms.CheckBox
$chkCommits.Text = 'Last 10 commits'
$chkCommits.Location = New-Object System.Drawing.Point(30, 290)
$chkCommits.AutoSize = $true
$chkCommits.Checked = $true

$chkChangelog = New-Object System.Windows.Forms.CheckBox
$chkChangelog.Text = 'CHANGELOG.md'
$chkChangelog.Location = New-Object System.Drawing.Point(280, 290)
$chkChangelog.AutoSize = $true

# Target
$lblTarget = New-Object System.Windows.Forms.Label
$lblTarget.Text = 'Where to send the prompt'
$lblTarget.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$lblTarget.Location = New-Object System.Drawing.Point(20, 330)
$lblTarget.AutoSize = $true

$rdoClipboard = New-Object System.Windows.Forms.RadioButton
$rdoClipboard.Text = 'Copy to clipboard + open Claude.ai in browser (recommended; no API cost)'
$rdoClipboard.Location = New-Object System.Drawing.Point(30, 350)
$rdoClipboard.AutoSize = $true
$rdoClipboard.Checked = $true

$rdoFile = New-Object System.Windows.Forms.RadioButton
$rdoFile.Text = 'Save assembled prompt to 02_active/critic-input-<date>.md (review before sending)'
$rdoFile.Location = New-Object System.Drawing.Point(30, 375)
$rdoFile.AutoSize = $true

$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.Text = ''
$lblOutput.Location = New-Object System.Drawing.Point(20, 420)
$lblOutput.Size = New-Object System.Drawing.Size(620, 80)
$lblOutput.ForeColor = [System.Drawing.Color]::FromArgb(0, 92, 192)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = 'Assemble + Send'
$btnRun.Location = New-Object System.Drawing.Point(20, 510)
$btnRun.Size = New-Object System.Drawing.Size(180, 38)
$btnRun.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnRun.ForeColor = [System.Drawing.Color]::White
$btnRun.FlatStyle = 'Flat'
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = 'Close'
$btnCancel.Location = New-Object System.Drawing.Point(520, 510)
$btnCancel.Size = New-Object System.Drawing.Size(120, 38)
$btnCancel.FlatStyle = 'System'
$btnCancel.Add_Click({ $form.Close() })

$btnRun.Add_Click({
    $btnRun.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $lblOutput.Text = 'Assembling context...'
    [System.Windows.Forms.Application]::DoEvents()

    try {
        # Critic Agent system prompt (embedded; based on Critic Agent 1.txt v2.0)
        $criticPrompt = @"
# SYSTEM PROMPT: WORLD-CLASS CRITIC AGENT v2.0

You are the Critic Agent - an elite evaluation system. Operate at the standard of a McKinsey senior partner combined with a principal engineer at a FAANG company.

## CORE PRINCIPLES
1. CRITIQUE BEFORE REVISION
2. STEELMAN FIRST
3. ROOT CAUSE OVER SYMPTOMS (Five Whys)
4. EVIDENCE-ANCHORED (cite specifics)
5. CALIBRATED CONFIDENCE (HIGH/MEDIUM/LOW)

## EVALUATION FRAMEWORK (MECE, 7 dimensions)
1. CORRECTNESS & ACCURACY (25%)
2. COMPLETENESS & COVERAGE (20%)
3. REASONING & STRUCTURE (15%)
4. PRACTICALITY & ACTIONABILITY (15%)
5. ROBUSTNESS & ANTI-FRAGILITY (10%)
6. EFFICIENCY & ELEGANCE (10%)
7. COMMUNICATION & CLARITY (5%)

Each dimension scored 1-5 with rubric. Severity per issue: CRITICAL / MAJOR / MINOR / NITPICK.

## OPERATING MODE
$($cmbMode.SelectedItem)

## OUTPUT FORMAT
JSON with: overall_score (0-100), verdict, executive_summary, steelman, dimension_scores, critical_issues (with recommendations + impact_effort), premortem_risks, strengths, meta_critique.

## FOCUS AREA FOR THIS CRITIQUE
$($txtFocus.Text)
"@

        # Gather context
        $context = New-Object System.Text.StringBuilder
        [void]$context.AppendLine("# Project context for critique")
        [void]$context.AppendLine("")
        [void]$context.AppendLine("**Project:** $(Split-Path $projectRoot -Leaf)")
        [void]$context.AppendLine("**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
        [void]$context.AppendLine("")

        if ($chkTree.Checked) {
            [void]$context.AppendLine("## File tree (top 100, excluding .git/node_modules)")
            [void]$context.AppendLine('```')
            Get-ChildItem $projectRoot -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch '\\\.git\\|\\node_modules\\|\\dist\\|\\build\\|\\coverage\\' } |
                Select-Object -First 100 |
                ForEach-Object { [void]$context.AppendLine($_.FullName.Substring($projectRoot.Length).TrimStart('\', '/')) }
            [void]$context.AppendLine('```')
            [void]$context.AppendLine("")
        }

        $docFiles = @{}
        if ($chkReadme.Checked)    { $docFiles['README.md']     = Join-Path $projectRoot 'README.md' }
        if ($chkAgents.Checked)    { $docFiles['AGENTS.md']     = Join-Path $projectRoot 'AGENTS.md' }
        if ($chkStatus.Checked)    { $docFiles['STATUS.md']     = Join-Path $projectRoot 'STATUS.md' }
        if ($chkChangelog.Checked) { $docFiles['CHANGELOG.md']  = Join-Path $projectRoot 'CHANGELOG.md' }
        foreach ($name in $docFiles.Keys) {
            $p = $docFiles[$name]
            if (Test-Path $p) {
                [void]$context.AppendLine("## $name (excerpt, first 4000 chars)")
                $content = (Get-Content $p -Raw -ErrorAction SilentlyContinue)
                if ($content) {
                    $excerpt = if ($content.Length -gt 4000) { $content.Substring(0, 4000) + "`n[...truncated...]" } else { $content }
                    [void]$context.AppendLine('```markdown')
                    [void]$context.AppendLine($excerpt)
                    [void]$context.AppendLine('```')
                }
                [void]$context.AppendLine("")
            }
        }

        if ($chkCommits.Checked -and (Test-Path (Join-Path $projectRoot '.git'))) {
            [void]$context.AppendLine("## Last 10 commits")
            [void]$context.AppendLine('```')
            try { (& git -C $projectRoot log --oneline -10 2>&1) -join "`n" | ForEach-Object { [void]$context.AppendLine($_) } } catch {}
            [void]$context.AppendLine('```')
            [void]$context.AppendLine("")
        }

        $fullPrompt = $criticPrompt + "`n`n---`n`n" + $context.ToString()

        if ($rdoClipboard.Checked) {
            Set-Clipboard -Value $fullPrompt
            Start-Process 'https://claude.ai/new'
            $lblOutput.Text = "OK: Prompt copied to clipboard ($([math]::Round($fullPrompt.Length / 1024, 1)) KB).`r`nClaude.ai opened in browser.`r`nPaste with Ctrl+V."
        } else {
            $activeDir = Join-Path $projectRoot '02_active'
            if (-not (Test-Path $activeDir)) { New-Item -ItemType Directory -Path $activeDir -Force | Out-Null }
            $file = Join-Path $activeDir "critic-input-$(Get-Date -Format 'yyyy-MM-dd').md"
            [System.IO.File]::WriteAllText($file, $fullPrompt, [System.Text.UTF8Encoding]::new($false))
            $lblOutput.Text = "OK: Prompt saved to:`r`n$file`r`n`r`nReview, edit if needed, then paste into Claude."
            try { Invoke-Item $file } catch {}
        }
    } catch {
        $lblOutput.ForeColor = [System.Drawing.Color]::FromArgb(192, 0, 0)
        $lblOutput.Text = "FAILED: $_"
    } finally {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
        $btnRun.Enabled = $true
    }
})

$form.Controls.AddRange(@(
    $lblTitle, $lblSub,
    $lblMode, $cmbMode,
    $lblFocus, $txtFocus,
    $lblInclude, $chkTree, $chkReadme, $chkAgents, $chkStatus, $chkCommits, $chkChangelog,
    $lblTarget, $rdoClipboard, $rdoFile,
    $lblOutput, $btnRun, $btnCancel
))
$form.AcceptButton = $btnRun
$form.CancelButton = $btnCancel

[void]$form.ShowDialog()
$form.Dispose()

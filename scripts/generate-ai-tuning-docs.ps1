#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Auto-generates docs/instructions/ and docs/prompts/ from their source directories.

.DESCRIPTION
    Reads each instructions/*.instructions.md and prompts/*.prompt.md, generates
    documentation pages in docs/instructions/ and docs/prompts/, and adds/updates
    the Instructions and Prompts sections of docs/toc.yml.
    The docs/instructions/ and docs/prompts/ directories are gitignored — run this
    script before building docs.

.EXAMPLE
    ./scripts/generate-ai-tuning-docs.ps1
    ./scripts/generate-ai-tuning-docs.ps1 -RepoRoot ./ -DocsRoot ./docs
#>
param(
    [string]$RepoRoot = "$PSScriptRoot/..",
    [string]$DocsRoot = "$PSScriptRoot/../docs"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path $RepoRoot
$DocsRoot = Resolve-Path $DocsRoot
$InstructionsRoot = Join-Path $RepoRoot "instructions"
$PromptsRoot = Join-Path $RepoRoot "prompts"
$TocPath = Join-Path $DocsRoot "toc.yml"

$RepoSlug = "IntelliTect/IntelliPlugins"
$RepoBranch = "main"
$RawBase = "https://raw.githubusercontent.com/$RepoSlug/$RepoBranch"

function Get-VsCodeInstallLinks {
    param(
        [string]$RelativePath,  # e.g. "instructions/csharp.instructions.md"
        [string]$UriScheme      # "chat-instructions", "chat-prompt", etc.
    )

    $rawUrl = "$RawBase/$RelativePath"
    $encodedRaw = [Uri]::EscapeDataString($rawUrl)
    $stableUri = "vscode:$UriScheme/install?url=$encodedRaw"
    $insidersUri = "vscode-insiders:$UriScheme/install?url=$encodedRaw"

    return @{
        StableUri     = $stableUri
        InsidersUri   = $insidersUri
        StableBadge   = "[![Open in VS Code](https://img.shields.io/badge/VS_Code-Install-0078d4?logo=visualstudiocode)]($stableUri)"
        InsidersBadge = "[![Open in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install-24bfa5?logo=visualstudiocode)]($insidersUri)"
    }
}

function Get-FrontmatterAndBody {
    param([string]$Content)

    $frontmatter = @{}
    $body = $Content

    if ($Content -match '(?s)^---\r?\n(.+?)\r?\n---\r?\n(.*)$') {
        $yamlBlock = $Matches[1]
        $body = $Matches[2].TrimStart()

        foreach ($line in ($yamlBlock -split '\r?\n')) {
            # Array value must be checked before scalar: tools: ['a', 'b']
            if ($line -match "^(\w+):\s*\[(.+)\]\s*$") {
                $frontmatter[$Matches[1]] = ($Matches[2] -split ',\s*' | ForEach-Object { $_.Trim(" '`"") })
            }
            elseif ($line -match "^(\w+):\s*'?(.+?)'?\s*$") {
                $frontmatter[$Matches[1]] = $Matches[2]
            }
        }
    }

    return @{ Frontmatter = $frontmatter; Body = $body }
}

function Get-H1Title {
    param([string]$Body)
    if ($Body -match '(?m)^#\s+(.+)') {
        return $Matches[1].Trim()
    }
    return $null
}

function Get-BodyWithoutH1 {
    param([string]$Body)
    return ($Body -replace '(?m)^#\s+.+\r?\n(\r?\n)?', '').TrimStart()
}

function Update-TocSection {
    param(
        [string]$TocContent,
        [string]$SectionName,
        [string]$NewSectionYaml
    )

    # Replace an existing section or insert before Guides
    $escapedName = [regex]::Escape($SectionName)
    $sectionPattern = "(?m)^- name: $escapedName\r?\n(?:[ \t]+.*\r?\n)*"

    # If no new section content is provided, remove the section if it exists
    if ([string]::IsNullOrWhiteSpace($NewSectionYaml)) {
        if ($TocContent -match $sectionPattern) {
            $updated = $TocContent -replace $sectionPattern, ""
            # Keep spacing tidy after removal
            return ($updated -replace '(\r?\n){3,}', "`n`n").TrimEnd() + "`n"
        }
        return $TocContent
    }

    if ($TocContent -match $sectionPattern) {
        return $TocContent -replace $sectionPattern, "$NewSectionYaml`n"
    }

    # Insert before Guides section if it exists, otherwise append before end
    if ($TocContent -match '(?m)^- name: Guides') {
        return $TocContent -replace '(?m)(^- name: Guides)', "$NewSectionYaml`n`$1"
    }

    return $TocContent.TrimEnd() + "`n`n$NewSectionYaml`n"
}

# ── Instructions ──────────────────────────────────────────────────────────────

$DocsInstructionsDir = Join-Path $DocsRoot "instructions"
if (-not (Test-Path $DocsInstructionsDir)) {
    New-Item -Path $DocsInstructionsDir -ItemType Directory -Force | Out-Null
    Write-Host " Created directory: docs/instructions/"
}

$generatedInstructions = @()

if (Test-Path $InstructionsRoot) {
    $instructionFiles = Get-ChildItem -Path $InstructionsRoot -Filter "*.instructions.md" | Sort-Object Name

    foreach ($file in $instructionFiles) {
        $raw = Get-Content $file.FullName -Raw
        $parsed = Get-FrontmatterAndBody -Content $raw
        $fm = $parsed.Frontmatter
        $body = $parsed.Body

        $slug = $file.Name -replace '\.instructions\.md$', ''
        $title = Get-H1Title -Body $body
        if (-not $title) { $title = $slug }
        $bodyWithoutH1 = Get-BodyWithoutH1 -Body $body

        $description = if ($fm.description) { $fm.description } else { "" }
        $applyTo = if ($fm.applyTo) { $fm.applyTo } else { "*" }

        $installLinks = Get-VsCodeInstallLinks -RelativePath "instructions/$($file.Name)" -UriScheme "chat-instructions"

        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add("# $title")
        $lines.Add("")
        if ($description) {
            $lines.Add("**Description**: $description")
            $lines.Add("")
        }
        $lines.Add("**Applies To**: ``$applyTo``")
        $lines.Add("")
        $lines.Add("**Install**: $($installLinks.StableBadge) $($installLinks.InsidersBadge)")
        $lines.Add("")
        $lines.Add("---")
        $lines.Add("")
        $lines.Add($bodyWithoutH1.TrimEnd())
        $lines.Add("")
        $lines.Add("---")
        $lines.Add("")
        $lines.Add("[← Back to Instructions](index.md)")
        $lines.Add("")

        $docContent = $lines -join "`n"
        $outputPath = Join-Path $DocsInstructionsDir "$slug.md"
        [System.IO.File]::WriteAllText($outputPath, $docContent, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "   Generated: docs/instructions/$slug.md"

        $generatedInstructions += [PSCustomObject]@{
            Slug        = $slug
            Title       = $title
            Description = $description
            ApplyTo     = $applyTo
            File        = "instructions/$slug.md"
            StableUri   = $installLinks.StableUri
            InsidersUri = $installLinks.InsidersUri
        }
    }
}
else {
    Write-Warning "instructions/ directory not found at $InstructionsRoot"
}

# Generate docs/instructions/index.md
$instructionRows = ($generatedInstructions | ForEach-Object {
        $installCell = "[VS Code]($($_.StableUri)) / [Insiders]($($_.InsidersUri))"
        "| [$($_.Title)]($($_.Slug).md) | ``$($_.ApplyTo)`` | $($_.Description) | $installCell |"
    }) -join "`n"

$indexLines = [System.Collections.Generic.List[string]]::new()
$indexLines.Add("# Instructions")
$indexLines.Add("")
$indexLines.Add("Copilot instruction files that automatically apply context and coding standards when working in matching files.")
$indexLines.Add("")
$indexLines.Add("## Available Instructions")
$indexLines.Add("")
$indexLines.Add("| Instruction | Applies To | Description | Install |")
$indexLines.Add("|-------------|------------|-------------|---------|")
if ($instructionRows) { $indexLines.Add($instructionRows) }
$indexLines.Add("")

$indexContent = $indexLines -join "`n"
$indexPath = Join-Path $DocsInstructionsDir "index.md"
[System.IO.File]::WriteAllText($indexPath, $indexContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "   Generated: docs/instructions/index.md"

# ── Prompts ───────────────────────────────────────────────────────────────────

$DocsPromptsDir = Join-Path $DocsRoot "prompts"
if (-not (Test-Path $DocsPromptsDir)) {
    New-Item -Path $DocsPromptsDir -ItemType Directory -Force | Out-Null
    Write-Host " Created directory: docs/prompts/"
}

$generatedPrompts = @()

if (Test-Path $PromptsRoot) {
    $promptFiles = Get-ChildItem -Path $PromptsRoot -Filter "*.prompt.md" | Sort-Object Name

    foreach ($file in $promptFiles) {
        $raw = Get-Content $file.FullName -Raw
        $parsed = Get-FrontmatterAndBody -Content $raw
        $fm = $parsed.Frontmatter
        $body = $parsed.Body

        $slug = $file.Name -replace '\.prompt\.md$', ''
        $title = Get-H1Title -Body $body
        if (-not $title) { $title = $slug }
        $bodyWithoutH1 = Get-BodyWithoutH1 -Body $body

        $description = if ($fm.description) { $fm.description } else { "" }
        $mode = if ($fm.mode) { $fm.mode } else { "" }
        $tools = if ($fm.tools -is [array]) { $fm.tools -join ", " } elseif ($fm.tools) { $fm.tools } else { "" }

        $installLinks = Get-VsCodeInstallLinks -RelativePath "prompts/$($file.Name)" -UriScheme "chat-prompt"

        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add("# $title")
        $lines.Add("")
        if ($description) {
            $lines.Add("**Description**: $description")
            $lines.Add("")
        }
        if ($mode) { $lines.Add("**Mode**: $mode") }
        if ($tools) { $lines.Add("**Tools**: $tools") }
        if ($mode -or $tools) { $lines.Add("") }
        $lines.Add("**Install**: $($installLinks.StableBadge) $($installLinks.InsidersBadge)")
        $lines.Add("")
        $lines.Add("---")
        $lines.Add("")
        $lines.Add($bodyWithoutH1.TrimEnd())
        $lines.Add("")
        $lines.Add("---")
        $lines.Add("")
        $lines.Add("[← Back to Prompts](index.md)")
        $lines.Add("")

        $docContent = $lines -join "`n"
        $outputPath = Join-Path $DocsPromptsDir "$slug.md"
        [System.IO.File]::WriteAllText($outputPath, $docContent, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "   Generated: docs/prompts/$slug.md"

        $generatedPrompts += [PSCustomObject]@{
            Slug        = $slug
            Title       = $title
            Description = $description
            Mode        = $mode
            File        = "prompts/$slug.md"
            StableUri   = $installLinks.StableUri
            InsidersUri = $installLinks.InsidersUri
        }
    }
}
else {
    Write-Warning "prompts/ directory not found at $PromptsRoot"
}

# Generate docs/prompts/index.md
$promptRows = ($generatedPrompts | ForEach-Object {
        $installCell = "[VS Code]($($_.StableUri)) / [Insiders]($($_.InsidersUri))"
        "| [$($_.Title)]($($_.Slug).md) | $($_.Mode) | $($_.Description) | $installCell |"
    }) -join "`n"

$promptIndexLines = [System.Collections.Generic.List[string]]::new()
$promptIndexLines.Add("# Prompts")
$promptIndexLines.Add("")
$promptIndexLines.Add("Reusable Copilot prompt files for common development workflows.")
$promptIndexLines.Add("")
$promptIndexLines.Add("## Available Prompts")
$promptIndexLines.Add("")
$promptIndexLines.Add("| Prompt | Mode | Description | Install |")
$promptIndexLines.Add("|--------|------|-------------|---------|")
if ($promptRows) { $promptIndexLines.Add($promptRows) }
$promptIndexLines.Add("")

$promptIndexContent = $promptIndexLines -join "`n"
$promptIndexPath = Join-Path $DocsPromptsDir "index.md"
[System.IO.File]::WriteAllText($promptIndexPath, $promptIndexContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "   Generated: docs/prompts/index.md"

# ── Update toc.yml ────────────────────────────────────────────────────────────

Write-Host ""
Write-Host " Updating toc.yml..."

$tocContent = Get-Content $TocPath -Raw

# Build Instructions toc section
$instructionItems = ($generatedInstructions | ForEach-Object {
        "  - name: $($_.Title)`n    href: $($_.File)"
    }) -join "`n"
$instructionsSection = ""
if ($generatedInstructions.Count -gt 0) {
    $instructionsSection = "- name: Instructions`n  items:`n  - name: Overview`n    href: instructions/index.md"
    if ($instructionItems) { $instructionsSection += "`n$instructionItems" }
}

# Build Prompts toc section
$promptItems = ($generatedPrompts | ForEach-Object {
        "  - name: $($_.Title)`n    href: $($_.File)"
    }) -join "`n"
$promptsSection = ""
if ($generatedPrompts.Count -gt 0) {
    $promptsSection = "- name: Prompts`n  items:`n  - name: Overview`n    href: prompts/index.md"
    if ($promptItems) { $promptsSection += "`n$promptItems" }
}

$tocContent = Update-TocSection -TocContent $tocContent -SectionName "Instructions" -NewSectionYaml $instructionsSection
$tocContent = Update-TocSection -TocContent $tocContent -SectionName "Prompts" -NewSectionYaml $promptsSection

[System.IO.File]::WriteAllText($TocPath, $tocContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "   Updated toc.yml with Instructions ($($generatedInstructions.Count) entries) and Prompts ($($generatedPrompts.Count) entries)"
Write-Host ""
Write-Host " Done! Generated $($generatedInstructions.Count + 1) instruction doc(s) and $($generatedPrompts.Count + 1) prompt doc(s)."

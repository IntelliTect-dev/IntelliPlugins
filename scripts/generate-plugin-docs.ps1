#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Auto-generates docs/plugins/ from plugins/ — the single source of truth.

.DESCRIPTION
    Reads each plugins/*/plugin.json and plugins/*/README.md, generates documentation pages
    in docs/plugins/, and rebuilds the plugin section of docs/toc.yml.
    The docs/plugins/ directory is gitignored — run this script before building docs.

.EXAMPLE
    ./scripts/generate-plugin-docs.ps1
    ./scripts/generate-plugin-docs.ps1 -PluginsRoot ./plugins -DocsRoot ./docs
#>
param(
    [string]$PluginsRoot = "$PSScriptRoot/../plugins",
    [string]$DocsRoot = "$PSScriptRoot/../docs"
)

$ErrorActionPreference = "Stop"

$PluginsRoot = Resolve-Path $PluginsRoot
$DocsRoot = Resolve-Path $DocsRoot
$DocsPluginsDir = Join-Path $DocsRoot "plugins"
$TocPath = Join-Path $DocsRoot "toc.yml"

# Create docs/plugins/ if it doesn't exist (it's gitignored)
if (-not (Test-Path $DocsPluginsDir)) {
    New-Item -Path $DocsPluginsDir -ItemType Directory -Force | Out-Null
    Write-Host " Created directory: docs/plugins/"
}

Write-Host " Scanning plugins in: $PluginsRoot"
Write-Host " Generating docs in:  $DocsPluginsDir"
Write-Host ""

$pluginDirs = Get-ChildItem -Path $PluginsRoot -Directory | Sort-Object Name

if ($pluginDirs.Count -eq 0) {
    Write-Warning "No plugin directories found in $PluginsRoot"
    exit 0
}

# Category mapping: plugin category values -> toc section name
$categoryMap = @{
    "Enterprise"   = "Enterprise"
    "Architecture" = "Enterprise"
    "Language"     = "Enterprise"
    "Code Quality" = "Enterprise"
    "Framework"    = "Framework"
    "Vuetify"      = "Framework"
    "Coalesce"     = "Framework"
    "Vue"          = "Framework"
    "Specialized"  = "Specialized"
    "Bug"          = "Specialized"
    "Debugging"    = "Specialized"
}

$generated = @()

foreach ($dir in $pluginDirs) {
    $pluginJsonPath = Join-Path $dir.FullName "plugin.json"
    $readmePath = Join-Path $dir.FullName "README.md"

    if (-not (Test-Path $pluginJsonPath)) {
        Write-Warning "  Skipping $($dir.Name): no plugin.json found"
        continue
    }

    $plugin = Get-Content $pluginJsonPath -Raw | ConvertFrom-Json

    # Read README body — strip the H1 title since we generate a consistent header
    $readmeContent = ""
    if (Test-Path $readmePath) {
        $readmeContent = Get-Content $readmePath -Raw
        $readmeContent = $readmeContent -replace '(?m)^#\s+.+\r?\n(\r?\n)?', ''
        $readmeContent = $readmeContent.TrimStart()
    }

    # Rewrite relative links to plugin-internal files (e.g. instructions/*.md) into GitHub source URLs
    # so they don't become broken links in the generated docs site
    $repoUrl = ""
    if ($plugin.repository -and $plugin.repository.url) {
        $repoUrl = $plugin.repository.url -replace '\.git$', ''
    } elseif ($plugin.publisher) {
        $repoUrl = "https://github.com/$($plugin.publisher)/IntelliPlugins"
    }
    if ($repoUrl -and $readmeContent) {
        $pluginDir = "plugins/$($plugin.name)"
        # Match markdown links like [text](relative/path.md) that don't start with http or #
        $readmeContent = [regex]::Replace($readmeContent, '\[([^\]]+)\]\((?!http|#)([^)]+)\)', {
            param($m)
            $text = $m.Groups[1].Value
            $href = $m.Groups[2].Value
            "[$text]($repoUrl/blob/main/$pluginDir/$href)"
        })
    }

    # Determine toc category
    $tocCategory = "Specialized"
    if ($plugin.categories) {
        foreach ($cat in $plugin.categories) {
            if ($categoryMap.ContainsKey($cat)) {
                $tocCategory = $categoryMap[$cat]
                break
            }
        }
    }

    $keywordsStr   = if ($plugin.keywords)   { $plugin.keywords   -join ", " } else { "" }
    $categoriesStr = if ($plugin.categories) { $plugin.categories -join ", " } else { "" }
    $installCmd    = "copilot plugin install $($plugin.name)@IntelliPlugins"

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# $($plugin.displayName)")
    $lines.Add("")
    $lines.Add("**Version**: $($plugin.version) | **Category**: $categoriesStr | **Publisher**: $($plugin.publisher)")
    $lines.Add("")
    $lines.Add("**Install**: ``$installCmd``")
    if ($keywordsStr) {
        $lines.Add("")
        $lines.Add("**Keywords**: $keywordsStr")
    }
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add($readmeContent.TrimEnd())
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add("[← Back to Plugins](installation-guide.md)")
    $lines.Add("")

    $docContent = $lines -join "`n"
    $outputPath = Join-Path $DocsPluginsDir "$($plugin.name).md"
    [System.IO.File]::WriteAllText($outputPath, $docContent, (New-Object System.Text.UTF8Encoding $false))

    Write-Host "   Generated: docs/plugins/$($plugin.name).md"

    $generated += [PSCustomObject]@{
        Name        = $plugin.name
        DisplayName = $plugin.displayName
        TocCategory = $tocCategory
        File        = "plugins/$($plugin.name).md"
    }
}

# Generate installation-guide.md from plugin data
Write-Host ""
Write-Host " Generating installation guide..."

$installRows = ($generated | Sort-Object Name | ForEach-Object {
    "| $($_.DisplayName) | ``copilot plugin install $($_.Name)@IntelliPlugins`` |"
}) -join "`n"

$installAllCmds = ($generated | Sort-Object Name | ForEach-Object {
    "copilot plugin install $($_.Name)@IntelliPlugins"
}) -join " && \`n"

$configPlugins = ($generated | Sort-Object Name | ForEach-Object {
    "    `"$($_.Name)@IntelliPlugins`""
}) -join ",`n"

$installGuideLines = [System.Collections.Generic.List[string]]::new()
$installGuideLines.Add("# Installing IntelliPlugins")
$installGuideLines.Add("")
$installGuideLines.Add("## Prerequisites")
$installGuideLines.Add("")
$installGuideLines.Add("- GitHub Copilot CLI ([installation guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/getting-started-with-github-copilot-cli))")
$installGuideLines.Add("- Git installed on your system")
$installGuideLines.Add("")
$installGuideLines.Add("## Available Plugins")
$installGuideLines.Add("")
$installGuideLines.Add("| Plugin | Install Command |")
$installGuideLines.Add("|--------|-----------------|")
$installGuideLines.Add($installRows)
$installGuideLines.Add("")
$installGuideLines.Add("## Install from Marketplace")
$installGuideLines.Add("")
$installGuideLines.Add('```bash')
$installGuideLines.Add("copilot plugin marketplace add IntelliTect/IntelliPlugins")
$installGuideLines.Add('```')
$installGuideLines.Add("")
$installGuideLines.Add("## Install All Plugins")
$installGuideLines.Add("")
$installGuideLines.Add('```bash')
$installGuideLines.Add($installAllCmds)
$installGuideLines.Add('```')
$installGuideLines.Add("")
$installGuideLines.Add("## Project-Level Setup")
$installGuideLines.Add("")
$installGuideLines.Add("Create `.copilot/config.json` in your project to share plugin config with the team:")
$installGuideLines.Add("")
$installGuideLines.Add('```json')
$installGuideLines.Add("{")
$installGuideLines.Add('  "plugins": [')
$installGuideLines.Add($configPlugins)
$installGuideLines.Add("  ]")
$installGuideLines.Add("}")
$installGuideLines.Add('```')
$installGuideLines.Add("")
$installGuideLines.Add("## Verify Installation")
$installGuideLines.Add("")
$installGuideLines.Add('```bash')
$installGuideLines.Add("copilot plugin list")
$installGuideLines.Add('```')
$installGuideLines.Add("")

$installGuideContent = $installGuideLines -join "`n"
$installGuidePath = Join-Path $DocsPluginsDir "installation-guide.md"
[System.IO.File]::WriteAllText($installGuidePath, $installGuideContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host "   Generated: docs/plugins/installation-guide.md"

# Rebuild toc.yml plugin section (surgical replacement — preserves all other sections)
Write-Host ""
Write-Host " Rebuilding toc.yml (Plugins section only)..."

$tocContent = Get-Content $TocPath -Raw

$pluginItems = ($generated | Sort-Object DisplayName | ForEach-Object {
    "  - name: $($_.DisplayName)`n    href: $($_.File)"
}) -join "`n"

$pluginsSection = "- name: Plugins`n  items:`n  - name: Installation Guide`n    href: plugins/installation-guide.md`n$pluginItems"

# Replace existing Plugins section in-place; insert before the first non-Home top-level
# section if it doesn't exist yet
if ($tocContent -match '(?m)^- name: Plugins\r?\n(?:[ \t]+.*\r?\n)*') {
    $tocContent = $tocContent -replace '(?m)^- name: Plugins\r?\n(?:[ \t]+.*\r?\n)*', "$pluginsSection`n"
} elseif ($tocContent -match '(?m)^- name: Guides') {
    $tocContent = $tocContent -replace '(?m)(^- name: Guides)', "$pluginsSection`n`n`$1"
} else {
    $tocContent = $tocContent.TrimEnd() + "`n`n$pluginsSection`n"
}

[System.IO.File]::WriteAllText($TocPath, $tocContent, (New-Object System.Text.UTF8Encoding $false))

Write-Host "   Updated Plugins section in toc.yml with $($generated.Count) plugin entries"
Write-Host ""
Write-Host " Done! Generated $($generated.Count + 1) file(s) from plugins/ source."

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$vaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$masterPath = Join-Path $vaultRoot '_graph\MC 项目总览.md'
$excludeRegex = '\\.obsidian\\|\\build\\|\\.gradle\\|\\.nav-backup\\|\\useful_recipes_1\.21\.1_neoforge\\'

if (-not (Test-Path -LiteralPath $masterPath)) { throw "Master index not found: $masterPath" }

$everyMarkdown = @(Get-ChildItem -LiteralPath $vaultRoot -Recurse -File -Filter *.md -Force)
$excludedCount = @($everyMarkdown | Where-Object { $_.FullName -match '\\useful_recipes_1\.21\.1_neoforge\\' }).Count
$allMarkdown = @($everyMarkdown | Where-Object { $_.FullName -notmatch $excludeRegex })
$indexed = @($allMarkdown | Where-Object { $_.FullName -ne $masterPath })

function Get-NoteTitle {
    param([string] $Path, [string] $Fallback)
    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    foreach ($line in ($raw -split "`r?`n")) {
        if ($line -match '^#\s+(.+?)\s*$') { return $Matches[1].Trim() }
    }
    return $Fallback
}

function Get-NoteGroup {
    param([string] $Rel)
    $parts = $Rel -split '/'
    if ($parts.Count -eq 1) { return '(根目录)' }
    if ($parts[0] -eq '_graph') {
        if ($parts.Count -ge 2 -and $parts[1] -eq 'entities') {
            if ($parts.Count -ge 4) { return "$($parts[0])/$($parts[1])/$($parts[2])" }
            return '_graph/entities'
        }
        return '_graph'
    }
    return $parts[0]
}

$records = foreach ($file in $indexed) {
    $rel = $file.FullName.Substring($vaultRoot.Length + 1).Replace('\','/')
    $fallback = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    [pscustomobject]@{
        Rel = $rel
        Title = Get-NoteTitle -Path $file.FullName -Fallback $fallback
        Group = Get-NoteGroup -Rel $rel
    }
}

$groupOrder = @('(根目录)','bonded_companions','_graph','_graph/entities','_graph/entities/生物','_graph/entities/物品','_graph/entities/附魔','_graph/entities/系统')
$groups = $records | Group-Object Group | Sort-Object @{ Expression = { $i = $groupOrder.IndexOf($_.Name); if ($i -lt 0) { 1000 } else { $i } } }, Name

$lines = [Collections.Generic.List[string]]::new()
$lines.Add('<!-- BEGIN AUTO-INDEX -->')
$lines.Add('> [!example]- 全量文档索引（自动生成，勿手改）')
$lines.Add('> 运行 `_graph/tools/update-vault-index.ps1` 重新生成；自动排除 `useful_recipes_1.21.1_neoforge/`、`.nav-backup/`、`build/`、`.gradle/`。')
$lines.Add('>')
foreach ($group in $groups) {
    $lines.Add("> **$($group.Name)（$($group.Count)）**")
    foreach ($record in ($group.Group | Sort-Object Rel)) {
        $lines.Add("> - [[$($record.Rel)|$($record.Title)]]")
    }
    $lines.Add('>')
}
$lines.Add('<!-- END AUTO-INDEX -->')

$content = Get-Content -LiteralPath $masterPath -Raw -Encoding UTF8
$pattern = '(?s)<!-- BEGIN AUTO-INDEX -->.*?<!-- END AUTO-INDEX -->'
if ($content -notmatch $pattern) { throw 'AUTO-INDEX markers not found in master.' }
$replacement = [string]::Join("`r`n", $lines)
$updated = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement }, 1)
[IO.File]::WriteAllText($masterPath, $updated, (New-Object System.Text.UTF8Encoding($true)))

Write-Output "VAULT_MD $($allMarkdown.Count)"
Write-Output "INDEXED $($records.Count)"
Write-Output "EXCLUDED_USEFUL_RECIPES $excludedCount"
Write-Output "GROUPS $($groups.Count)"
Write-Output "MASTER_UPDATED $masterPath"

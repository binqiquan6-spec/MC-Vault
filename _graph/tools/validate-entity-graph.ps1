[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$vaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$graphRoot = Join-Path $vaultRoot '_graph'
$errors = [Collections.Generic.List[string]]::new()

function Add-Error {
    param([string] $Message)
    $errors.Add($Message)
}

$markdownFiles = @(Get-ChildItem -LiteralPath $graphRoot -Recurse -File -Filter *.md)
$wikilinkCount = 0
foreach ($file in $markdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $content = [regex]::Replace($content, '(?s)```.*?```', '')
    $content = [regex]::Replace($content, '`[^`]*`', '')
    foreach ($match in [regex]::Matches($content, '\[\[([^\]]+)\]\]')) {
        $wikilinkCount++
        $inner = $match.Groups[1].Value.Replace('\|','|')
        $target = (($inner -split '\|', 2)[0] -split '#', 2)[0].Trim()
        $candidates = @($target, "$target.md", "$target.canvas") | Select-Object -Unique
        $exists = $candidates | Where-Object {
            Test-Path -LiteralPath (Join-Path $vaultRoot $_)
        }
        if (-not $exists) {
            Add-Error "Broken wikilink: $($file.FullName) -> $target"
        }
    }
}

$entityNotes = @(
    Get-ChildItem -LiteralPath (Join-Path $graphRoot 'entities') -Directory |
        Where-Object Name -in @('生物', '物品', '附魔', '系统') |
        ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -File -Filter *.md }
)
foreach ($file in $entityNotes) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($heading in @('## 当前状态', '## 属性', '## 能力与功能', '## 关系', '## 依据')) {
        if (-not $content.Contains($heading)) {
            Add-Error "Missing entity section '$heading': $($file.FullName)"
        }
    }
}

$creatureNotes = @(Get-ChildItem -LiteralPath (Join-Path $graphRoot 'entities\生物') -File -Filter *.md)
if ($creatureNotes.Count -ne 13) {
    Add-Error "Expected 13 creature notes, got $($creatureNotes.Count)"
}
foreach ($file in $creatureNotes) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -notmatch '- 物品：\[\[') {
        Add-Error "Creature has no linked item: $($file.FullName)"
    }
}

$canvasFiles = @(Get-ChildItem -LiteralPath $graphRoot -File -Filter *.canvas)
$canvasNodeCount = 0
$canvasEdgeCount = 0
foreach ($file in $canvasFiles) {
    try {
        $canvas = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    } catch {
        Add-Error "Invalid canvas JSON: $($file.Name)"
        continue
    }

    $canvasNodeCount += $canvas.nodes.Count
    $canvasEdgeCount += $canvas.edges.Count
    $nodeIds = @($canvas.nodes.id)
    if (($nodeIds | Sort-Object -Unique).Count -ne $nodeIds.Count) {
        Add-Error "Duplicate canvas node ID: in $($file.Name)"
    }

    foreach ($node in ($canvas.nodes | Where-Object type -eq 'file')) {
        if (-not (Test-Path -LiteralPath (Join-Path $vaultRoot $node.file))) {
            Add-Error "Missing canvas file: $($node.file)"
        }
    }

    foreach ($edge in $canvas.edges) {
        if ($edge.fromNode -notin $nodeIds -or $edge.toNode -notin $nodeIds) {
            Add-Error "Broken canvas edge: $($file.Name)/$($edge.id)"
        }
    }

    for ($i = 0; $i -lt $canvas.nodes.Count; $i++) {
        for ($j = $i + 1; $j -lt $canvas.nodes.Count; $j++) {
            $a = $canvas.nodes[$i]
            $b = $canvas.nodes[$j]
            $overlap =
                ($a.x -lt ($b.x + $b.width)) -and
                (($a.x + $a.width) -gt $b.x) -and
                ($a.y -lt ($b.y + $b.height)) -and
                (($a.y + $a.height) -gt $b.y)
            if ($overlap) {
                Add-Error "Canvas overlap: $($file.Name)/$($a.id)/$($b.id)"
            }
        }
    }
}

$recipeRoot = Join-Path $vaultRoot 'bonded_companions\src\main\resources\data\bonded_companions\recipe'
$recipeIds = @(
    Get-ChildItem -LiteralPath $recipeRoot -File -Filter *.json |
        Select-Object -ExpandProperty BaseName |
        Sort-Object
)
$generatedItemIds = @(
    Get-ChildItem -LiteralPath (Join-Path $graphRoot 'entities\物品') -File -Filter *.md |
        ForEach-Object {
            $raw = Get-Content -LiteralPath $_.FullName -Raw
            if ($raw -match 'registry_id: "bonded_companions:([^"]+)"') {
                $Matches[1]
            }
        } |
        Sort-Object
)
$itemDiff = @(Compare-Object $recipeIds $generatedItemIds)
if ($itemDiff.Count -gt 0) {
    Add-Error "Generated custom item IDs do not match recipe IDs."
}

$enchantmentRoot = Join-Path $vaultRoot 'bonded_companions\src\main\resources\data\bonded_companions\enchantment'
$enchantmentIds = @(
    Get-ChildItem -LiteralPath $enchantmentRoot -File -Filter *.json |
        Select-Object -ExpandProperty BaseName |
        Sort-Object
)
$generatedEnchantmentIds = @(
    Get-ChildItem -LiteralPath (Join-Path $graphRoot 'entities\附魔') -File -Filter *.md |
        ForEach-Object {
            $raw = Get-Content -LiteralPath $_.FullName -Raw
            if ($raw -match 'registry_id: "bonded_companions:([^"]+)"') {
                $Matches[1]
            }
        } |
        Sort-Object
)
$enchantmentDiff = @(Compare-Object $enchantmentIds $generatedEnchantmentIds)
if ($enchantmentDiff.Count -gt 0) {
    Add-Error "Generated enchantment IDs do not match enchantment data IDs."
}

$manifestPath = Join-Path $graphRoot 'PROTECTED-FILES.sha256'
foreach ($line in (Get-Content -LiteralPath $manifestPath)) {
    if ($line -notmatch '^([0-9A-F]{64})  (.+)$') {
        Add-Error "Malformed protected hash line: $line"
        continue
    }
    $expected = $Matches[1]
    $protectedPath = Join-Path $vaultRoot $Matches[2]
    $actual = (Get-FileHash -LiteralPath $protectedPath -Algorithm SHA256).Hash
    if ($actual -ne $expected) {
        Add-Error "Protected file changed: $protectedPath"
    }
}

try {
    $graphConfig = Get-Content -LiteralPath (Join-Path $vaultRoot '.obsidian\graph.json') -Raw | ConvertFrom-Json
    if ($graphConfig.colorGroups.Count -ne 10) {
        Add-Error "Expected 10 graph color groups, got $($graphConfig.colorGroups.Count)"
    }
} catch {
    Add-Error 'Invalid .obsidian/graph.json'
}

Write-Output "MARKDOWN_NOTES $($markdownFiles.Count)"
Write-Output "ENTITY_NOTES $($entityNotes.Count)"
Write-Output "WIKILINKS $wikilinkCount"
Write-Output "CANVAS_FILES $($canvasFiles.Count)"
Write-Output "CANVAS_TOTAL_NODES $canvasNodeCount"
Write-Output "CANVAS_TOTAL_EDGES $canvasEdgeCount"
Write-Output "CUSTOM_ITEM_IDS $($generatedItemIds.Count)"
Write-Output "CUSTOM_ENCHANTMENT_IDS $($generatedEnchantmentIds.Count)"

if ($errors.Count -gt 0) {
    Write-Output 'FAIL'
    $errors | ForEach-Object { Write-Output $_ }
    exit 1
}

Write-Output 'PASS all validations'



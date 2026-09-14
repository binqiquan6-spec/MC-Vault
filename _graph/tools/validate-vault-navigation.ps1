[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$vaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$masterRel = '_graph/MC 项目总览.md'
$masterPath = Join-Path $vaultRoot $masterRel
$errors = [Collections.Generic.List[string]]::new()
$warnings = [Collections.Generic.List[string]]::new()

function Add-Err([string] $m) { $errors.Add($m) }
function Add-Warn([string] $m) { $warnings.Add($m) }

$excludeRegex = '\\.obsidian\\|\\build\\|\\.gradle\\|\\.nav-backup\\|\\useful_recipes_1\.21\.1_neoforge\\'
if (-not (Test-Path -LiteralPath $masterPath)) { Add-Err "Master entry not found: $masterRel" }

$allFiles = @(Get-ChildItem -LiteralPath $vaultRoot -Recurse -File -Force | Where-Object { $_.FullName -notmatch $excludeRegex })
$mdFiles = @($allFiles | Where-Object { $_.Extension -eq '.md' })
$canvasFiles = @($allFiles | Where-Object { $_.Extension -eq '.canvas' })

$relMap = @{}
foreach ($f in $mdFiles) { $rel = $f.FullName.Substring($vaultRoot.Length + 1).Replace('\','/'); $relMap[$rel] = $f.FullName }
$nameToRel = @{}
foreach ($rel in $relMap.Keys) {
    $base = [IO.Path]::GetFileNameWithoutExtension($rel)
    if (-not $nameToRel.ContainsKey($base)) { $nameToRel[$base] = New-Object Collections.ArrayList }
    [void]$nameToRel[$base].Add($rel)
}
$attachmentNameToPath = @{}
foreach ($f in $allFiles) { if (-not $attachmentNameToPath.ContainsKey($f.Name)) { $attachmentNameToPath[$f.Name] = $f.FullName } }

$inbound = @{}
$adj = @{}
foreach ($rel in $relMap.Keys) { $inbound[$rel] = 0; $adj[$rel] = New-Object Collections.ArrayList }

function Resolve-Target([string] $target) {
    $t = $target.Trim().Replace('\','/')
    if ($t.StartsWith('/')) { $t = $t.Substring(1) }
    if ([string]::IsNullOrWhiteSpace($t)) { return $null }

    $exact = Join-Path $vaultRoot $t
    if (Test-Path -LiteralPath $exact -PathType Leaf) {
        return [pscustomobject]@{ Rel = $t; Path = $exact; IsMd = $exact.EndsWith('.md') }
    }
    foreach ($ext in @('.md','.canvas')) {
        $candidate = Join-Path $vaultRoot ($t + $ext)
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return [pscustomobject]@{ Rel = $t + $ext; Path = $candidate; IsMd = ($ext -eq '.md') }
        }
    }
    $base = $t
    $slash = $base.LastIndexOf('/')
    if ($slash -ge 0) { $base = $base.Substring($slash + 1) }
    if ($nameToRel.ContainsKey($base)) {
        $rel = $nameToRel[$base][0]
        return [pscustomobject]@{ Rel = $rel; Path = $relMap[$rel]; IsMd = $true }
    }
    if ($base -match '\.[A-Za-z0-9]+$' -and $attachmentNameToPath.ContainsKey($base)) {
        return [pscustomobject]@{ Rel = $base; Path = $attachmentNameToPath[$base]; IsMd = $false }
    }
    return $null
}

function Get-Headings([string] $path) {
    $raw = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $list = New-Object Collections.Generic.List[string]
    foreach ($line in ($raw -split "`r?`n")) {
        if ($line -match '^#{1,6}\s+(.+?)\s*#*\s*$') { [void]$list.Add($Matches[1].Trim()) }
    }
    return $list
}

$totalLinks = 0
$brokenLinks = 0
$headingWarnings = 0
foreach ($file in $mdFiles) {
    $sourceRel = $file.FullName.Substring($vaultRoot.Length + 1).Replace('\','/')
    $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $raw = [regex]::Replace($raw, '(?s)```.*?```', '')
    $raw = [regex]::Replace($raw, '`[^`]*`', '')
    foreach ($m in [regex]::Matches($raw, '\[\[([^\]]+)\]\]')) {
        $totalLinks++
        $inner = $m.Groups[1].Value.Replace('\|','|')
        $parts = $inner -split '\|', 2
        $targetPart = $parts[0].Trim()
        if ([string]::IsNullOrWhiteSpace($targetPart)) { continue }
        $heading = ''
        $hash = $targetPart.IndexOf('#')
        if ($hash -ge 0) { $heading = $targetPart.Substring($hash + 1); $targetPart = $targetPart.Substring(0, $hash) }
        $resolved = Resolve-Target $targetPart
        if (-not $resolved) {
            $brokenLinks++
            Add-Err "Broken wikilink: $sourceRel -> $targetPart"
            continue
        }
        if ($resolved.IsMd) {
            if ($inbound.ContainsKey($resolved.Rel)) { $inbound[$resolved.Rel]++ }
            if ($adj.ContainsKey($sourceRel)) { [void]$adj[$sourceRel].Add($resolved.Rel) }
            if ($heading) {
                $headings = Get-Headings $resolved.Path
                $found = $false
                foreach ($h in $headings) { if ($h -eq $heading.Trim()) { $found = $true; break } }
                if (-not $found) {
                    $headingWarnings++
                    Add-Warn "Heading anchor not found: $sourceRel -> $($resolved.Rel)#$heading"
                }
            }
        }
    }
}

$orphans = @($relMap.Keys | Where-Object { $inbound[$_] -eq 0 })
foreach ($rel in $orphans) { Add-Err "No inbound wikilink: $rel" }

$depth = @{}
$depth[$masterRel] = 0
$queue = New-Object Collections.Queue
$queue.Enqueue($masterRel)
while ($queue.Count -gt 0) {
    $node = $queue.Dequeue()
    if (-not $adj.ContainsKey($node)) { continue }
    foreach ($next in $adj[$node]) {
        if (-not $depth.ContainsKey($next)) {
            $depth[$next] = $depth[$node] + 1
            $queue.Enqueue($next)
        }
    }
}
$unreachable = @($relMap.Keys | Where-Object { -not $depth.ContainsKey($_) })
foreach ($rel in $unreachable) { Add-Err "Unreachable from master: $rel" }
$maxDepth = 0; foreach ($d in $depth.Values) { if ($d -gt $maxDepth) { $maxDepth = $d } }

$masterRaw = Get-Content -LiteralPath $masterPath -Raw -Encoding UTF8
if ($masterRaw -match '\[\[[^\]]*useful_recipes_1\.21\.1_neoforge[^\]]*\]\]') {
    Add-Err 'Master entry links to the excluded useful_recipes folder.'
}
foreach ($rel in $relMap.Keys) {
    if ($rel -like 'useful_recipes_1.21.1_neoforge/*') { Add-Err "Excluded folder leaked into processed Markdown: $rel" }
}

$protectedOk = $true
$manifest = Join-Path $vaultRoot '_graph\PROTECTED-FILES.sha256'
if (Test-Path -LiteralPath $manifest) {
    foreach ($line in (Get-Content -LiteralPath $manifest -Encoding UTF8)) {
        if ($line -notmatch '^([0-9A-Fa-f]{64})  (.+)$') { continue }
        $expected = $Matches[1].ToUpper(); $rel = $Matches[2].Trim()
        $file = Join-Path $vaultRoot ($rel.Replace('/','\'))
        if (-not (Test-Path -LiteralPath $file)) { Add-Err "Protected file missing: $rel"; $protectedOk = $false; continue }
        $actual = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpper()
        if ($actual -ne $expected) { Add-Err "Protected file changed: $rel"; $protectedOk = $false }
    }
} else { Add-Err "Protected hash manifest missing: $manifest" }

$colorGroups = -1
$graphPath = Join-Path $vaultRoot '.obsidian\graph.json'
if (Test-Path -LiteralPath $graphPath) {
    try { $graph = Get-Content -LiteralPath $graphPath -Raw -Encoding UTF8 | ConvertFrom-Json; $colorGroups = @($graph.colorGroups).Count } catch { Add-Err 'Invalid .obsidian/graph.json' }
} else { Add-Err '.obsidian/graph.json missing' }
if ($colorGroups -ne 10) { Add-Err "Expected 10 graph color groups, got $colorGroups" }

$bookmarkStatus = 'missing'
$bookmarkPath = Join-Path $vaultRoot '.obsidian\bookmarks.json'
if (Test-Path -LiteralPath $bookmarkPath) {
    try { $null = Get-Content -LiteralPath $bookmarkPath -Raw -Encoding UTF8 | ConvertFrom-Json; $bookmarkStatus = 'valid' } catch { Add-Err 'Invalid .obsidian/bookmarks.json'; $bookmarkStatus = 'invalid' }
}

Write-Output "PROCESSED_MD $($mdFiles.Count)"
Write-Output "WIKILINKS $totalLinks"
Write-Output "BROKEN $brokenLinks"
Write-Output "ORPHANS $($orphans.Count)"
Write-Output "UNREACHABLE $($unreachable.Count)"
Write-Output "MAX_DEPTH $maxDepth"
Write-Output "HEADING_WARNINGS $headingWarnings"
Write-Output "PROTECTED_HASHES $(if($protectedOk){'PASS'}else{'FAIL'})"
Write-Output "GRAPH_COLOR_GROUPS $colorGroups"
Write-Output "BOOKMARKS $bookmarkStatus"

if ($warnings.Count -gt 0) {
    Write-Output 'WARNINGS:'
    foreach ($w in $warnings) { Write-Output "WARN $w" }
}
if ($errors.Count -gt 0) {
    Write-Output 'FAIL'
    foreach ($e in $errors) { Write-Output "ERROR $e" }
    exit 1
}
Write-Output 'PASS all navigation validations'

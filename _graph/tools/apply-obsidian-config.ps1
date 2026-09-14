[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$vaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$obsidianDir = Join-Path $vaultRoot '.obsidian'
$logDir = Join-Path $vaultRoot '.nav-backup'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir 'apply-obsidian-config.log'

function Write-Log([string] $message) {
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $message"
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
    Write-Output $message
}

$running = @(Get-Process -Name Obsidian -ErrorAction SilentlyContinue)
if ($running.Count -gt 0) {
    Write-Log "ABORT: Obsidian is running ($($running.Count) processes). Close Obsidian completely, then re-run."
    exit 2
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# 1) 10 graph color groups
$graphPath = Join-Path $obsidianDir 'graph.json'
$graph = Get-Content -LiteralPath $graphPath -Raw -Encoding UTF8 | ConvertFrom-Json
$colors = @(
    @{ query = 'path:bonded_companions'; color = @{ a = 1; rgb = 10395294 } },
    @{ query = 'path:_graph'; color = @{ a = 1; rgb = 12171705 } },
    @{ query = 'path:_graph/entities'; color = @{ a = 1; rgb = 10233776 } },
    @{ query = 'path:_graph/entities/生物'; color = @{ a = 1; rgb = 5025616 } },
    @{ query = 'path:_graph/entities/物品'; color = @{ a = 1; rgb = 48340 } },
    @{ query = 'path:_graph/entities/附魔'; color = @{ a = 1; rgb = 15277667 } },
    @{ query = 'path:_graph/entities/系统'; color = @{ a = 1; rgb = 16750592 } },
    @{ query = 'path:_graph/MC 项目总览'; color = @{ a = 1; rgb = 16761095 } },
    @{ query = 'path:_graph/Bonded Companions'; color = @{ a = 1; rgb = 16007990 } },
    @{ query = 'file:MC 模组开发工具清单'; color = @{ a = 1; rgb = 2336036 } }
)
$graph.colorGroups = @($colors)
$graphJson = $graph | ConvertTo-Json -Depth 10
[IO.File]::WriteAllText($graphPath, $graphJson, $utf8NoBom)
Write-Log "graph.json: colorGroups=$(@($colors).Count)"

# 2) bookmarks
$bookmarksPath = Join-Path $obsidianDir 'bookmarks.json'
$now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$fileBookmark = {
    param([string] $path, [string] $title, [long] $ctime)
    [ordered]@{ type = 'file'; ctime = $ctime; path = $path; title = $title }
}
$items = @(
    & $fileBookmark '_graph/MC 项目总览.md' '总目录' ($now + 1)
    & $fileBookmark '_graph/entities/Bonded Companions 实体索引.md' '实体索引' ($now + 2)
    & $fileBookmark 'bonded_companions/PRD.md' 'PRD' ($now + 3)
    & $fileBookmark 'bonded_companions/Tech-Spec.md' 'Tech-Spec' ($now + 4)
    & $fileBookmark 'bonded_companions/IMPLEMENTATION-STATUS.md' 'IMPLEMENTATION-STATUS' ($now + 5)
    & $fileBookmark 'bonded_companions/DEVELOPMENT-EXECUTION-PLAN.md' '当前任务卡' ($now + 6)
    & $fileBookmark '_graph/MC 项目关系图.canvas' 'MC 项目关系图' ($now + 7)
    & $fileBookmark '_graph/Bonded Companions 实体关系图.canvas' '实体关系图' ($now + 8)
)
$bookmarks = [ordered]@{
    items = @(
        [ordered]@{
            type = 'group'
            ctime = $now
            title = '导航'
            items = $items
        }
    )
}
$bookmarkJson = $bookmarks | ConvertTo-Json -Depth 10
[IO.File]::WriteAllText($bookmarksPath, $bookmarkJson, $utf8NoBom)
Write-Log "bookmarks.json: items=$($items.Count)"

# 3) enable installed plugins
$communityPath = Join-Path $obsidianDir 'community-plugins.json'
$enabled = @()
if (Test-Path -LiteralPath $communityPath) {
    try { $enabled = @(Get-Content -LiteralPath $communityPath -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { $enabled = @() }
}
foreach ($pluginId in @('folder-overview','obsidian-git','homepage')) {
    $pluginManifest = Join-Path $obsidianDir ("plugins\$pluginId\manifest.json")
    if ((Test-Path -LiteralPath $pluginManifest) -and ($enabled -notcontains $pluginId)) {
        $enabled += $pluginId
        Write-Log "enabled plugin: $pluginId"
    }
}
if ($enabled.Count -gt 0) {
    [IO.File]::WriteAllText($communityPath, ($enabled | ConvertTo-Json), $utf8NoBom)
    Write-Log "community-plugins.json: $($enabled -join ', ')"
} else {
    Write-Log 'community-plugins.json: no installed plugins found'
}

# 4) validate JSON
foreach ($p in @($graphPath, $bookmarksPath, $communityPath)) {
    if (Test-Path -LiteralPath $p) {
        $null = Get-Content -LiteralPath $p -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-Log "JSON OK: $([IO.Path]::GetFileName($p))"
    }
}
Write-Log 'DONE'

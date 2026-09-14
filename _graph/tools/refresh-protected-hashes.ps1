[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$vaultRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$projectRoot = Join-Path $vaultRoot 'bonded_companions'
$manifestPath = Join-Path $vaultRoot '_graph\PROTECTED-FILES.sha256'
$protectedFiles = @(
    'AGENTS.md',
    'ART-DIRECTION.md',
    'DEVELOPMENT-RULES.md',
    'IMPLEMENTATION-STATUS.md',
    'MEMORY.md',
    'PRD.md',
    'README.md',
    'RECIPES.md',
    'Tech-Spec.md'
)

$lines = foreach ($name in $protectedFiles) {
    $filePath = Join-Path $projectRoot $name
    if (-not (Test-Path -LiteralPath $filePath)) {
        throw "Protected file does not exist: $filePath"
    }
    $hash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash
    "$hash  bonded_companions/$name"
}

Set-Content -LiteralPath $manifestPath -Value ($lines -join "`n") -Encoding utf8
Write-Output "Updated $manifestPath with $($lines.Count) hashes."

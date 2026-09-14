param(
    [Parameter(Mandatory = $true)]
    [string]$JarPath,

    [Parameter(Mandatory = $true)]
    [string]$BackupDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedOriginalHash = '03C41153E70BB9B605557F9E7FFA90F20576E2B5DCE19A33EC3FEEC7BB92CEC4'
$targetEntryName = 'data/etn/worldgen/placed_feature/lake_water_surface.json'
$correctedJson = @'
{
  "feature": "etn:lake_water",
  "placement": [
    {
      "type": "minecraft:count",
      "count": {
        "type": "minecraft:weighted_list",
        "distribution": [
          {
            "weight": 2,
            "data": {
              "type": "minecraft:biased_to_bottom",
              "min_inclusive": 5,
              "max_inclusive": 15
            }
          },
          {
            "weight": 3,
            "data": 1
          }
        ]
      }
    },
    {
      "type": "minecraft:in_square"
    },
    {
      "type": "minecraft:heightmap",
      "heightmap": "WORLD_SURFACE_WG"
    },
    {
      "type": "minecraft:biome"
    }
  ]
}
'@

if (-not (Test-Path -LiteralPath $JarPath -PathType Leaf)) {
    throw "Target JAR does not exist: $JarPath"
}

$originalHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $JarPath).Hash
if ($originalHash -ne $expectedOriginalHash) {
    throw "Target JAR hash does not match the inspected original. Expected $expectedOriginalHash, got $originalHash"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$originalArchive = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
try {
    $originalEntryCount = $originalArchive.Entries.Count
    $originalEntry = $originalArchive.GetEntry($targetEntryName)
    if ($null -eq $originalEntry) {
        throw "Target JSON entry is missing: $targetEntryName"
    }

    $reader = [System.IO.StreamReader]::new($originalEntry.Open())
    try {
        $originalJson = $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }

    if ($originalJson -notmatch '"type"\s*:\s*"minecraft:biased_to_bottom"\s*,\s*"value"\s*:') {
        throw 'The expected incompatible nested value structure was not found.'
    }
}
finally {
    $originalArchive.Dispose()
}

New-Item -ItemType Directory -Force -Path $BackupDirectory | Out-Null
$backupPath = Join-Path $BackupDirectory ([System.IO.Path]::GetFileName($JarPath))
if (Test-Path -LiteralPath $backupPath) {
    $backupHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $backupPath).Hash
    if ($backupHash -ne $expectedOriginalHash) {
        throw "Backup path already contains a different file: $backupPath"
    }
}
else {
    Copy-Item -LiteralPath $JarPath -Destination $backupPath
}

$jarDirectory = Split-Path -Parent $JarPath
$temporaryPath = Join-Path $jarDirectory ('.codex-epicterrain-' + [guid]::NewGuid().ToString('N') + '.jar')
Copy-Item -LiteralPath $JarPath -Destination $temporaryPath

try {
    $patchArchive = [System.IO.Compression.ZipFile]::Open($temporaryPath, [System.IO.Compression.ZipArchiveMode]::Update)
    try {
        $entry = $patchArchive.GetEntry($targetEntryName)
        if ($null -eq $entry) {
            throw "Target JSON entry disappeared from temporary JAR: $targetEntryName"
        }

        $entry.Delete()
        $newEntry = $patchArchive.CreateEntry($targetEntryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $writer = [System.IO.StreamWriter]::new($newEntry.Open(), [System.Text.UTF8Encoding]::new($false))
        try {
            $writer.Write($correctedJson)
        }
        finally {
            $writer.Dispose()
        }
    }
    finally {
        $patchArchive.Dispose()
    }

    $verificationArchive = [System.IO.Compression.ZipFile]::OpenRead($temporaryPath)
    try {
        if ($verificationArchive.Entries.Count -ne $originalEntryCount) {
            throw "Archive entry count changed unexpectedly: $originalEntryCount -> $($verificationArchive.Entries.Count)"
        }

        $verificationEntry = $verificationArchive.GetEntry($targetEntryName)
        if ($null -eq $verificationEntry) {
            throw "Patched JSON entry is missing: $targetEntryName"
        }

        $reader = [System.IO.StreamReader]::new($verificationEntry.Open())
        try {
            $verifiedJson = $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }

        if ($verifiedJson -ne $correctedJson) {
            throw 'Patched JSON did not pass exact-content verification.'
        }
    }
    finally {
        $verificationArchive.Dispose()
    }

    [System.IO.File]::Move($temporaryPath, $JarPath, $true)
}
finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath
    }
}

$patchedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $JarPath).Hash
"BACKUP=$backupPath"
"ORIGINAL_SHA256=$originalHash"
"PATCHED_SHA256=$patchedHash"
"ENTRY_COUNT=$originalEntryCount"
"PATCHED_ENTRY=$targetEntryName"

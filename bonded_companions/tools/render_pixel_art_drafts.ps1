param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\artwork\drafts\phase-1')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$palette = @{
    '.' = [System.Drawing.Color]::Transparent
    'o' = [System.Drawing.ColorTranslator]::FromHtml('#161005')
    's' = [System.Drawing.ColorTranslator]::FromHtml('#312104')
    'b' = [System.Drawing.ColorTranslator]::FromHtml('#654B17')
    'h' = [System.Drawing.ColorTranslator]::FromHtml('#8A611E')
    'q' = [System.Drawing.ColorTranslator]::FromHtml('#B7B7B7')
    'm' = [System.Drawing.ColorTranslator]::FromHtml('#A2B0BE')
    'r' = [System.Drawing.ColorTranslator]::FromHtml('#8A2D26')
    'g' = [System.Drawing.ColorTranslator]::FromHtml('#496B2A')
}

$targetLedger = @(
    '................',
    '......ooo.......',
    '....oobboo......',
    '...osbbbbmo.....',
    '..osbbbbbbmo....',
    '..osbbhbbbbmo...',
    '.osbbbssbbbmo...',
    '.osbbbsmssbbmo..',
    '.osbbbbssbbmo...',
    'osbbbbbbbbmo....',
    'osbbbbbbbqmo....',
    '.osbbbbqqmo.....',
    '..osbbqqqmo.....',
    '...oqqqorog.....',
    '....ooorog......',
    '................'
)

$targetLedgerV2 = @(
    '................',
    '.....ooooooo....',
    '....osbbbbbbo...',
    '....osbbbbbbmo..',
    '....osbbbbbbmo..',
    '...osbbbbbbbmo..',
    '...osbbbbbbbmo..',
    '...osbbsssbbmo..',
    '...osbbsmsbbmo..',
    '...osbbsssbbmo..',
    '..osbbbbbbbmo...',
    '..osbbbbbbqmo...',
    '..osbbbbbqqmo...',
    '...ooooqqqqo....',
    '.....orr.ogg....',
    '................'
)

function New-PixelSprite {
    param(
        [string[]]$Rows,
        [hashtable]$Colors
    )

    if ($Rows.Count -ne 16) {
        throw "Expected 16 rows, found $($Rows.Count)."
    }

    $bitmap = [System.Drawing.Bitmap]::new(16, 16, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y = 0; $y -lt 16; $y++) {
        if ($Rows[$y].Length -ne 16) {
            $bitmap.Dispose()
            throw "Row $y must contain exactly 16 cells."
        }

        for ($x = 0; $x -lt 16; $x++) {
            $key = [string]$Rows[$y][$x]
            if (-not $Colors.ContainsKey($key)) {
                $bitmap.Dispose()
                throw "Unknown palette key '$key' at ($x,$y)."
            }
            $bitmap.SetPixel($x, $y, $Colors[$key])
        }
    }
    return $bitmap
}

function Save-Preview {
    param(
        [System.Drawing.Bitmap]$Sprite,
        [string]$Path
    )

    $previewSize = 384
    $scale = 20
    $offset = 32
    $preview = [System.Drawing.Bitmap]::new($previewSize, $previewSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($preview)
    try {
        $light = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D8D8D8'))
        $dark = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#B8B8B8'))
        try {
            for ($y = 0; $y -lt $previewSize; $y += 16) {
                for ($x = 0; $x -lt $previewSize; $x += 16) {
                    $brush = if ((($x / 16) + ($y / 16)) % 2 -eq 0) { $light } else { $dark }
                    $graphics.FillRectangle($brush, $x, $y, 16, 16)
                }
            }
        }
        finally {
            $light.Dispose()
            $dark.Dispose()
        }

        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage($Sprite, [System.Drawing.Rectangle]::new($offset, $offset, 16 * $scale, 16 * $scale))
        $preview.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $preview.Dispose()
    }
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

$drafts = [ordered]@{
    'target_ledger_draft_v1' = $targetLedger
    'target_ledger_draft_v2' = $targetLedgerV2
}

foreach ($entry in $drafts.GetEnumerator()) {
    $spritePath = Join-Path $resolvedOutput ($entry.Key + '.png')
    $previewPath = Join-Path $resolvedOutput ($entry.Key + '_preview.png')
    if ((Test-Path -LiteralPath $spritePath) -and (Test-Path -LiteralPath $previewPath)) {
        continue
    }
    if ((Test-Path -LiteralPath $spritePath) -or (Test-Path -LiteralPath $previewPath)) {
        throw "Incomplete draft pair for $($entry.Key); refusing to overwrite it."
    }

    $sprite = New-PixelSprite -Rows $entry.Value -Colors $palette
    try {
        $sprite.Save($spritePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Save-Preview -Sprite $sprite -Path $previewPath
    }
    finally {
        $sprite.Dispose()
    }

    Write-Output $spritePath
    Write-Output $previewPath
}

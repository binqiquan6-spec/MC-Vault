param(
    [string]$InputPath = (Join-Path $PSScriptRoot '..\artwork\approved-concepts\target_ledger_concept_v1.png'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\artwork\review')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Get-OpaqueBounds {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$AlphaThreshold
    )

    $minX = $Bitmap.Width
    $minY = $Bitmap.Height
    $maxX = -1
    $maxY = -1
    for ($y = 0; $y -lt $Bitmap.Height; $y++) {
        for ($x = 0; $x -lt $Bitmap.Width; $x++) {
            if ($Bitmap.GetPixel($x, $y).A -lt $AlphaThreshold) {
                continue
            }
            $minX = [Math]::Min($minX, $x)
            $minY = [Math]::Min($minY, $y)
            $maxX = [Math]::Max($maxX, $x)
            $maxY = [Math]::Max($maxY, $y)
        }
    }

    if ($maxX -lt $minX -or $maxY -lt $minY) {
        throw 'The input image has no visible pixels.'
    }

    return [System.Drawing.Rectangle]::new($minX, $minY, $maxX - $minX + 1, $maxY - $minY + 1)
}

function Get-NearestPaletteColor {
    param(
        [System.Drawing.Color]$Color,
        [System.Drawing.Color[]]$Palette
    )

    $best = $Palette[0]
    $bestDistance = [double]::PositiveInfinity
    foreach ($candidate in $Palette) {
        $red = [int]$Color.R - [int]$candidate.R
        $green = [int]$Color.G - [int]$candidate.G
        $blue = [int]$Color.B - [int]$candidate.B
        $distance = ($red * $red) + ($green * $green) + ($blue * $blue)
        if ($distance -lt $bestDistance) {
            $bestDistance = $distance
            $best = $candidate
        }
    }
    return $best
}

function Save-NearestNeighborPreview {
    param(
        [System.Drawing.Bitmap]$Sprite,
        [string]$Path
    )

    $scale = 24
    $previewSize = 16 * $scale
    $preview = [System.Drawing.Bitmap]::new($previewSize, $previewSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($preview)
    try {
        $light = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D9EEF2'))
        $dark = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#BBDDE4'))
        try {
            for ($y = 0; $y -lt $previewSize; $y += $scale) {
                for ($x = 0; $x -lt $previewSize; $x += $scale) {
                    $brush = if ((($x / $scale) + ($y / $scale)) % 2 -eq 0) { $light } else { $dark }
                    $graphics.FillRectangle($brush, $x, $y, $scale, $scale)
                }
            }
        }
        finally {
            $light.Dispose()
            $dark.Dispose()
        }

        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage($Sprite, [System.Drawing.Rectangle]::new(0, 0, $previewSize, $previewSize))
        $preview.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $preview.Dispose()
    }
}

$resolvedInput = [System.IO.Path]::GetFullPath($InputPath)
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
if (-not [System.IO.File]::Exists($resolvedInput)) {
    throw "Input image not found: $resolvedInput"
}
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null

$spritePath = Join-Path $resolvedOutput 'target_ledger_16x16_v1.png'
$previewPath = Join-Path $resolvedOutput 'target_ledger_16x16_v1_preview.png'
if ([System.IO.File]::Exists($spritePath) -or [System.IO.File]::Exists($previewPath)) {
    throw 'Review output already exists; refusing to overwrite it.'
}

$palette = [System.Drawing.Color[]]@(
    [System.Drawing.ColorTranslator]::FromHtml('#161005'),
    [System.Drawing.ColorTranslator]::FromHtml('#312104'),
    [System.Drawing.ColorTranslator]::FromHtml('#44250A'),
    [System.Drawing.ColorTranslator]::FromHtml('#654B17'),
    [System.Drawing.ColorTranslator]::FromHtml('#8A611E'),
    [System.Drawing.ColorTranslator]::FromHtml('#585F68'),
    [System.Drawing.ColorTranslator]::FromHtml('#A2B0BE'),
    [System.Drawing.ColorTranslator]::FromHtml('#D9DFE7'),
    [System.Drawing.ColorTranslator]::FromHtml('#8A2D26'),
    [System.Drawing.ColorTranslator]::FromHtml('#496B2A')
)

$source = [System.Drawing.Bitmap]::new($resolvedInput)
try {
    $bounds = Get-OpaqueBounds -Bitmap $source -AlphaThreshold 128
    $targetHeight = 14
    $targetWidth = [Math]::Max(1, [Math]::Round($bounds.Width * $targetHeight / $bounds.Height))
    if ($targetWidth -gt 14) {
        $targetWidth = 14
        $targetHeight = [Math]::Max(1, [Math]::Round($bounds.Height * $targetWidth / $bounds.Width))
    }

    $scaled = [System.Drawing.Bitmap]::new($targetWidth, $targetHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $scaledGraphics = [System.Drawing.Graphics]::FromImage($scaled)
    try {
        $scaledGraphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $scaledGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $scaledGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $scaledGraphics.DrawImage(
            $source,
            [System.Drawing.Rectangle]::new(0, 0, $targetWidth, $targetHeight),
            $bounds,
            [System.Drawing.GraphicsUnit]::Pixel
        )
    }
    finally {
        $scaledGraphics.Dispose()
    }

    $sprite = [System.Drawing.Bitmap]::new(16, 16, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $offsetX = [Math]::Floor((16 - $targetWidth) / 2)
        $offsetY = [Math]::Floor((16 - $targetHeight) / 2)
        for ($y = 0; $y -lt $targetHeight; $y++) {
            for ($x = 0; $x -lt $targetWidth; $x++) {
                $pixel = $scaled.GetPixel($x, $y)
                if ($pixel.A -lt 128) {
                    continue
                }
                $quantized = Get-NearestPaletteColor -Color $pixel -Palette $palette
                $sprite.SetPixel($offsetX + $x, $offsetY + $y, [System.Drawing.Color]::FromArgb(255, $quantized.R, $quantized.G, $quantized.B))
            }
        }

        $sprite.Save($spritePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Save-NearestNeighborPreview -Sprite $sprite -Path $previewPath
    }
    finally {
        $sprite.Dispose()
        $scaled.Dispose()
    }
}
finally {
    $source.Dispose()
}

Write-Output $spritePath
Write-Output $previewPath

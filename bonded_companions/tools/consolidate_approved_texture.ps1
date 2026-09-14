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
        $distance = ($red * $red * 0.30) + ($green * $green * 0.59) + ($blue * $blue * 0.11)
        if ($distance -lt $bestDistance) {
            $bestDistance = $distance
            $best = $candidate
        }
    }
    return $best
}

function Save-Preview {
    param(
        [System.Drawing.Bitmap]$Sprite,
        [string]$Path
    )

    $scale = 6
    $size = 64 * $scale
    $preview = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($preview)
    try {
        $light = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D9EEF2'))
        $dark = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#BBDDE4'))
        try {
            for ($y = 0; $y -lt $size; $y += 12) {
                for ($x = 0; $x -lt $size; $x += 12) {
                    $brush = if ((($x / 12) + ($y / 12)) % 2 -eq 0) { $light } else { $dark }
                    $graphics.FillRectangle($brush, $x, $y, 12, 12)
                }
            }
        }
        finally {
            $light.Dispose()
            $dark.Dispose()
        }

        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage($Sprite, [System.Drawing.Rectangle]::new(0, 0, $size, $size))
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

$spritePath = Join-Path $resolvedOutput 'target_ledger_64x64_v1.png'
$previewPath = Join-Path $resolvedOutput 'target_ledger_64x64_v1_preview.png'
if ([System.IO.File]::Exists($spritePath) -or [System.IO.File]::Exists($previewPath)) {
    throw 'The 64x64 review output already exists; refusing to overwrite it.'
}

$palette = [System.Drawing.Color[]]@(
    [System.Drawing.ColorTranslator]::FromHtml('#140D08'),
    [System.Drawing.ColorTranslator]::FromHtml('#24150D'),
    [System.Drawing.ColorTranslator]::FromHtml('#332116'),
    [System.Drawing.ColorTranslator]::FromHtml('#4A2C17'),
    [System.Drawing.ColorTranslator]::FromHtml('#5E3512'),
    [System.Drawing.ColorTranslator]::FromHtml('#774314'),
    [System.Drawing.ColorTranslator]::FromHtml('#965A1A'),
    [System.Drawing.ColorTranslator]::FromHtml('#BC7925'),
    [System.Drawing.ColorTranslator]::FromHtml('#252A31'),
    [System.Drawing.ColorTranslator]::FromHtml('#4B4F56'),
    [System.Drawing.ColorTranslator]::FromHtml('#878C93'),
    [System.Drawing.ColorTranslator]::FromHtml('#CCD0D4'),
    [System.Drawing.ColorTranslator]::FromHtml('#9D978B'),
    [System.Drawing.ColorTranslator]::FromHtml('#E2DED4'),
    [System.Drawing.ColorTranslator]::FromHtml('#9A3029'),
    [System.Drawing.ColorTranslator]::FromHtml('#4E702C')
)

$source = [System.Drawing.Bitmap]::new($resolvedInput)
try {
    $bounds = Get-OpaqueBounds -Bitmap $source -AlphaThreshold 128
    $targetHeight = 60
    $targetWidth = [Math]::Max(1, [Math]::Round($bounds.Width * $targetHeight / $bounds.Height))
    if ($targetWidth -gt 60) {
        $targetWidth = 60
        $targetHeight = [Math]::Max(1, [Math]::Round($bounds.Height * $targetWidth / $bounds.Width))
    }

    $scaled = [System.Drawing.Bitmap]::new($targetWidth, $targetHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($scaled)
    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        $graphics.DrawImage(
            $source,
            [System.Drawing.Rectangle]::new(0, 0, $targetWidth, $targetHeight),
            $bounds,
            [System.Drawing.GraphicsUnit]::Pixel
        )
    }
    finally {
        $graphics.Dispose()
    }

    $sprite = [System.Drawing.Bitmap]::new(64, 64, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $offsetX = [Math]::Floor((64 - $targetWidth) / 2)
        $offsetY = [Math]::Floor((64 - $targetHeight) / 2)
        for ($y = 0; $y -lt $targetHeight; $y++) {
            for ($x = 0; $x -lt $targetWidth; $x++) {
                $pixel = $scaled.GetPixel($x, $y)
                if ($pixel.A -lt 128) {
                    continue
                }
                $color = Get-NearestPaletteColor -Color $pixel -Palette $palette
                $sprite.SetPixel($offsetX + $x, $offsetY + $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            }
        }

        $sprite.Save($spritePath, [System.Drawing.Imaging.ImageFormat]::Png)
        Save-Preview -Sprite $sprite -Path $previewPath
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

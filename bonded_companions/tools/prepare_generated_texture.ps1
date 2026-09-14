param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputBaseName,

    [Parameter(Mandatory = $true)]
    [string[]]$PaletteHex,

    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\artwork\review'),
    [switch]$RemoveLightChecker
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Test-LightNeutralPixel {
    param([System.Drawing.Color]$Color)

    if ($Color.A -lt 128) {
        return $true
    }
    $minimum = [Math]::Min($Color.R, [Math]::Min($Color.G, $Color.B))
    $maximum = [Math]::Max($Color.R, [Math]::Max($Color.G, $Color.B))
    return $minimum -ge 175 -and ($maximum - $minimum) -le 15
}

function Remove-ConnectedLightBackground {
    param([System.Drawing.Bitmap]$Source)

    $width = $Source.Width
    $height = $Source.Height
    $pixelCount = $width * $height
    $candidate = [bool[]]::new($pixelCount)
    $background = [bool[]]::new($pixelCount)

    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $index = ($y * $width) + $x
            $candidate[$index] = Test-LightNeutralPixel -Color $Source.GetPixel($x, $y)
        }
    }

    $queue = [System.Collections.Generic.Queue[int]]::new()
    function Add-BackgroundSeed {
        param([int]$Index)
        if ($candidate[$Index] -and -not $background[$Index]) {
            $background[$Index] = $true
            $queue.Enqueue($Index)
        }
    }

    for ($x = 0; $x -lt $width; $x++) {
        Add-BackgroundSeed -Index $x
        Add-BackgroundSeed -Index ((($height - 1) * $width) + $x)
    }
    for ($y = 0; $y -lt $height; $y++) {
        Add-BackgroundSeed -Index ($y * $width)
        Add-BackgroundSeed -Index (($y * $width) + $width - 1)
    }

    while ($queue.Count -gt 0) {
        $index = $queue.Dequeue()
        $x = $index % $width
        $y = [Math]::Floor($index / $width)
        if ($x -gt 0) { Add-BackgroundSeed -Index ($index - 1) }
        if ($x -lt $width - 1) { Add-BackgroundSeed -Index ($index + 1) }
        if ($y -gt 0) { Add-BackgroundSeed -Index ($index - $width) }
        if ($y -lt $height - 1) { Add-BackgroundSeed -Index ($index + $width) }
    }

    $result = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $index = ($y * $width) + $x
            if (-not $background[$index] -and $Source.GetPixel($x, $y).A -ge 128) {
                $color = $Source.GetPixel($x, $y)
                $result.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $color.R, $color.G, $color.B))
            }
        }
    }
    return $result
}

function Get-OpaqueBounds {
    param([System.Drawing.Bitmap]$Bitmap)

    $minX = $Bitmap.Width
    $minY = $Bitmap.Height
    $maxX = -1
    $maxY = -1
    for ($y = 0; $y -lt $Bitmap.Height; $y++) {
        for ($x = 0; $x -lt $Bitmap.Width; $x++) {
            if ($Bitmap.GetPixel($x, $y).A -lt 128) { continue }
            $minX = [Math]::Min($minX, $x)
            $minY = [Math]::Min($minY, $y)
            $maxX = [Math]::Max($maxX, $x)
            $maxY = [Math]::Max($maxY, $y)
        }
    }

    if ($maxX -lt $minX -or $maxY -lt $minY) {
        throw 'The input image has no visible pixels after background removal.'
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
    foreach ($candidateColor in $Palette) {
        $red = [int]$Color.R - [int]$candidateColor.R
        $green = [int]$Color.G - [int]$candidateColor.G
        $blue = [int]$Color.B - [int]$candidateColor.B
        $distance = ($red * $red * 0.30) + ($green * $green * 0.59) + ($blue * $blue * 0.11)
        if ($distance -lt $bestDistance) {
            $bestDistance = $distance
            $best = $candidateColor
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

$spritePath = Join-Path $resolvedOutput ($OutputBaseName + '.png')
$previewPath = Join-Path $resolvedOutput ($OutputBaseName + '_preview.png')
if ([System.IO.File]::Exists($spritePath) -or [System.IO.File]::Exists($previewPath)) {
    throw "Output already exists for $OutputBaseName; refusing to overwrite it."
}

$palette = [System.Drawing.Color[]]@(
    $PaletteHex | ForEach-Object { [System.Drawing.ColorTranslator]::FromHtml($_) }
)

$loaded = [System.Drawing.Bitmap]::new($resolvedInput)
$source = $null
try {
    $source = if ($RemoveLightChecker) { Remove-ConnectedLightBackground -Source $loaded } else { [System.Drawing.Bitmap]::new($loaded) }
    $bounds = Get-OpaqueBounds -Bitmap $source
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
        $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0, 0, $targetWidth, $targetHeight), $bounds, [System.Drawing.GraphicsUnit]::Pixel)
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
                if ($pixel.A -lt 128) { continue }
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
    if ($null -ne $source) { $source.Dispose() }
    $loaded.Dispose()
}

Write-Output $spritePath
Write-Output $previewPath

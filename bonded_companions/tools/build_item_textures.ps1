param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot
)

Add-Type -AssemblyName System.Drawing

$itemDirectory = Join-Path $ProjectRoot 'src/main/resources/assets/bonded_companions/textures/item'
$guiDirectory = Join-Path $ProjectRoot 'src/main/resources/assets/bonded_companions/textures/gui/icon'
$previewDirectory = Join-Path $ProjectRoot 'artwork/previews'
New-Item -ItemType Directory -Force -Path $itemDirectory, $guiDirectory, $previewDirectory | Out-Null

function New-Color([string]$hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

$color = @{
    Clear = [System.Drawing.Color]::Transparent
    Outline = New-Color '#1D1B1B'
    Shadow = New-Color '#33251D'
    LeatherDark = New-Color '#4A2B18'
    Leather = New-Color '#7A4928'
    LeatherLight = New-Color '#A86F3D'
    PageDark = New-Color '#B89A69'
    Page = New-Color '#E6D3A3'
    PageLight = New-Color '#F4E6BD'
    IronDark = New-Color '#55585D'
    Iron = New-Color '#A7ADB2'
    IronLight = New-Color '#D8DEE1'
    GoldDark = New-Color '#8B6514'
    Gold = New-Color '#D9AA21'
    GoldLight = New-Color '#F4D35A'
    DiamondDark = New-Color '#177C80'
    Diamond = New-Color '#2EB7B3'
    DiamondLight = New-Color '#73E1D7'
    NetheriteDark = New-Color '#342B32'
    Netherite = New-Color '#59464F'
    NetheriteLight = New-Color '#82646D'
    RedDark = New-Color '#71251F'
    Red = New-Color '#B63A2F'
    RedLight = New-Color '#E6634F'
    Orange = New-Color '#E97817'
    Yellow = New-Color '#F6C445'
    LapisDark = New-Color '#1F377B'
    Lapis = New-Color '#345EC3'
    LapisLight = New-Color '#6E91E3'
    AquaDark = New-Color '#155D67'
    Aqua = New-Color '#258F98'
    AquaLight = New-Color '#59C6C7'
    PinkDark = New-Color '#8E3F72'
    Pink = New-Color '#D46DA5'
    PinkLight = New-Color '#F2A0C8'
    GreenDark = New-Color '#34552C'
    Green = New-Color '#5D893D'
    GreenLight = New-Color '#8FBA56'
    White = New-Color '#F1F1E9'
    Black = New-Color '#111111'
}

function New-Sprite {
    $bitmap = [System.Drawing.Bitmap]::new(16, 16, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear($color.Clear)
    $graphics.Dispose()
    return $bitmap
}

function Set-Pixel($bitmap, [int]$x, [int]$y, $paint) {
    if ($x -ge 0 -and $x -lt 16 -and $y -ge 0 -and $y -lt 16) {
        $bitmap.SetPixel($x, $y, $paint)
    }
}

function Fill-Rect($bitmap, [int]$x, [int]$y, [int]$width, [int]$height, $paint) {
    for ($py = $y; $py -lt $y + $height; $py++) {
        for ($px = $x; $px -lt $x + $width; $px++) {
            Set-Pixel $bitmap $px $py $paint
        }
    }
}

function Draw-Line($bitmap, [int]$x0, [int]$y0, [int]$x1, [int]$y1, $paint) {
    $dx = [Math]::Abs($x1 - $x0)
    $sx = if ($x0 -lt $x1) { 1 } else { -1 }
    $dy = -[Math]::Abs($y1 - $y0)
    $sy = if ($y0 -lt $y1) { 1 } else { -1 }
    $error = $dx + $dy
    while ($true) {
        Set-Pixel $bitmap $x0 $y0 $paint
        if ($x0 -eq $x1 -and $y0 -eq $y1) { break }
        $twice = 2 * $error
        if ($twice -ge $dy) { $error += $dy; $x0 += $sx }
        if ($twice -le $dx) { $error += $dx; $y0 += $sy }
    }
}

function Draw-Frame($bitmap, [int]$x, [int]$y, [int]$width, [int]$height, $paint) {
    Fill-Rect $bitmap $x $y $width 1 $paint
    Fill-Rect $bitmap $x ($y + $height - 1) $width 1 $paint
    Fill-Rect $bitmap $x $y 1 $height $paint
    Fill-Rect $bitmap ($x + $width - 1) $y 1 $height $paint
}

function Save-Sprite([string]$directory, [string]$name, $bitmap) {
    try {
        $bitmap.Save((Join-Path $directory ($name + '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $bitmap.Dispose()
    }
}

function New-TargetLedger {
    $b = New-Sprite
    Fill-Rect $b 1 3 14 10 $color.Outline
    Fill-Rect $b 2 3 5 9 $color.Page
    Fill-Rect $b 9 3 5 9 $color.Page
    Set-Pixel $b 2 3 $color.Clear; Set-Pixel $b 13 3 $color.Clear
    Set-Pixel $b 1 3 $color.Clear; Set-Pixel $b 14 3 $color.Clear
    Fill-Rect $b 7 4 2 9 $color.LeatherDark
    Draw-Line $b 3 6 6 6 $color.PageDark
    Draw-Line $b 3 8 6 8 $color.PageDark
    Set-Pixel $b 11 5 $color.Red
    Fill-Rect $b 10 6 3 3 $color.White
    Set-Pixel $b 11 7 $color.RedDark
    Set-Pixel $b 10 5 $color.Red; Set-Pixel $b 12 5 $color.Red
    return $b
}

function New-SpikedCollar {
    $b = New-Sprite
    Fill-Rect $b 3 4 10 8 $color.Outline
    Fill-Rect $b 4 5 8 6 $color.RedDark
    Fill-Rect $b 5 6 6 4 $color.Clear
    Set-Pixel $b 4 5 $color.RedLight; Set-Pixel $b 11 5 $color.RedLight
    Fill-Rect $b 7 10 3 3 $color.Iron
    Set-Pixel $b 8 11 $color.Black
    foreach ($point in @(@(4,2), @(11,2), @(1,7), @(14,7))) {
        Set-Pixel $b $point[0] $point[1] $color.IronLight
    }
    Set-Pixel $b 4 3 $color.IronDark; Set-Pixel $b 11 3 $color.IronDark
    Set-Pixel $b 2 7 $color.IronDark; Set-Pixel $b 13 7 $color.IronDark
    return $b
}

function New-PetSatchel {
    $b = New-Sprite
    Draw-Line $b 5 4 6 2 $color.Outline; Draw-Line $b 6 2 10 2 $color.Outline; Draw-Line $b 10 2 11 4 $color.Outline
    Fill-Rect $b 3 4 10 10 $color.Outline
    Fill-Rect $b 4 5 8 8 $color.Leather
    Fill-Rect $b 4 5 8 3 $color.LeatherLight
    Draw-Line $b 4 8 11 8 $color.LeatherDark
    Fill-Rect $b 7 7 2 3 $color.Gold
    Set-Pixel $b 6 11 $color.Page; Set-Pixel $b 9 11 $color.Page
    Set-Pixel $b 7 10 $color.Page; Set-Pixel $b 8 10 $color.Page
    Set-Pixel $b 7 12 $color.Page; Set-Pixel $b 8 12 $color.Page
    return $b
}

function New-AxolotlHarness {
    $b = New-Sprite
    Fill-Rect $b 4 3 8 10 $color.Outline
    Fill-Rect $b 5 4 6 8 $color.Aqua
    Fill-Rect $b 7 5 2 6 $color.Clear
    Set-Pixel $b 5 4 $color.AquaLight; Set-Pixel $b 10 4 $color.AquaLight
    foreach ($point in @(@(2,4),@(1,6),@(2,8),@(13,4),@(14,6),@(13,8))) {
        Set-Pixel $b $point[0] $point[1] $color.Pink
    }
    Set-Pixel $b 3 5 $color.PinkLight; Set-Pixel $b 12 5 $color.PinkLight
    Fill-Rect $b 6 11 4 2 $color.IronDark
    return $b
}

function New-LapisTalisman {
    $b = New-Sprite
    Draw-Line $b 4 2 4 5 $color.GoldDark; Draw-Line $b 11 2 11 5 $color.GoldDark
    Draw-Line $b 4 2 7 4 $color.Gold; Draw-Line $b 11 2 8 4 $color.Gold
    Set-Pixel $b 7 4 $color.Outline; Set-Pixel $b 8 4 $color.Outline
    Fill-Rect $b 5 6 6 5 $color.Outline
    Fill-Rect $b 6 5 4 8 $color.Outline
    Fill-Rect $b 6 7 4 4 $color.Lapis
    Fill-Rect $b 7 6 2 6 $color.Lapis
    Set-Pixel $b 7 7 $color.LapisLight; Set-Pixel $b 8 10 $color.LapisDark
    return $b
}

function New-MoonfangBlade($dark, $mid, $light) {
    $b = New-Sprite
    Fill-Rect $b 2 12 4 3 $color.Outline
    Fill-Rect $b 3 12 2 2 $color.Leather
    Draw-Line $b 4 11 7 8 $color.Outline
    Draw-Line $b 5 11 8 8 $color.LeatherLight
    Fill-Rect $b 4 9 6 2 $color.Outline
    Fill-Rect $b 5 9 4 1 $color.GoldDark
    Draw-Line $b 7 9 12 3 $color.Outline
    Draw-Line $b 8 9 13 3 $mid
    Draw-Line $b 9 9 14 4 $color.Outline
    Set-Pixel $b 9 8 $light; Set-Pixel $b 10 7 $light; Set-Pixel $b 11 6 $light
    Set-Pixel $b 12 5 $light; Set-Pixel $b 13 4 $light; Set-Pixel $b 13 2 $light
    Set-Pixel $b 12 3 $mid; Set-Pixel $b 14 3 $dark
    Set-Pixel $b 10 8 $color.Clear; Set-Pixel $b 11 7 $color.Clear
    return $b
}

function New-ControlCore {
    $b = New-Sprite
    Fill-Rect $b 3 3 10 10 $color.Outline
    Fill-Rect $b 4 4 8 8 $color.LeatherLight
    Set-Pixel $b 4 4 $color.GoldLight; Set-Pixel $b 11 4 $color.GoldLight
    Set-Pixel $b 4 11 $color.GoldDark; Set-Pixel $b 11 11 $color.GoldDark
    Fill-Rect $b 6 5 4 6 $color.RedDark
    Fill-Rect $b 5 6 6 4 $color.RedDark
    Fill-Rect $b 7 6 2 4 $color.RedLight
    Fill-Rect $b 6 7 4 2 $color.RedLight
    Set-Pixel $b 7 7 $color.White
    return $b
}

function New-Reinforcement($dark, $mid, $light) {
    $b = New-Sprite
    Fill-Rect $b 2 4 12 9 $color.Outline
    Set-Pixel $b 2 4 $color.Clear; Set-Pixel $b 13 4 $color.Clear
    Fill-Rect $b 3 5 10 7 $mid
    Fill-Rect $b 5 4 6 1 $dark
    Draw-Line $b 4 6 11 6 $light
    foreach ($point in @(@(4,5),@(11,5),@(4,11),@(11,11))) {
        Set-Pixel $b $point[0] $point[1] $color.IronLight
    }
    Fill-Rect $b 7 7 2 4 $dark
    return $b
}

function New-HorsePackChest {
    $b = New-Sprite
    Fill-Rect $b 1 6 6 7 $color.Outline
    Fill-Rect $b 9 6 6 7 $color.Outline
    Fill-Rect $b 2 7 4 5 $color.Leather
    Fill-Rect $b 10 7 4 5 $color.Leather
    Fill-Rect $b 2 7 4 2 $color.LeatherLight
    Fill-Rect $b 10 7 4 2 $color.LeatherLight
    Fill-Rect $b 6 4 4 7 $color.Outline
    Fill-Rect $b 7 5 2 6 $color.Page
    Set-Pixel $b 5 9 $color.Iron; Set-Pixel $b 10 9 $color.Iron
    return $b
}

function New-DonkeyPackFrame {
    $b = New-Sprite
    Draw-Line $b 4 3 2 13 $color.Outline; Draw-Line $b 11 3 13 13 $color.Outline
    Draw-Line $b 5 3 3 13 $color.LeatherLight; Draw-Line $b 10 3 12 13 $color.LeatherLight
    Fill-Rect $b 4 5 8 2 $color.Outline; Fill-Rect $b 5 5 6 1 $color.Leather
    Fill-Rect $b 3 9 10 2 $color.Outline; Fill-Rect $b 4 9 8 1 $color.Leather
    Set-Pixel $b 2 13 $color.Iron; Set-Pixel $b 13 13 $color.Iron
    return $b
}

function New-MuleSortingPannier {
    $b = New-Sprite
    Fill-Rect $b 1 6 6 7 $color.Outline; Fill-Rect $b 9 6 6 7 $color.Outline
    Fill-Rect $b 2 7 4 5 $color.PageDark; Fill-Rect $b 10 7 4 5 $color.PageDark
    Fill-Rect $b 6 4 4 8 $color.LeatherDark
    Fill-Rect $b 7 5 2 5 $color.Page
    Set-Pixel $b 6 8 $color.Aqua; Set-Pixel $b 9 8 $color.Aqua
    Fill-Rect $b 7 10 2 2 $color.AquaDark
    return $b
}

function New-CamelCaravanRack {
    $b = New-Sprite
    Fill-Rect $b 3 5 10 8 $color.Outline
    Fill-Rect $b 4 6 8 6 $color.GoldDark
    Fill-Rect $b 5 3 6 4 $color.Outline
    Fill-Rect $b 6 4 4 2 $color.Red
    Fill-Rect $b 5 7 6 2 $color.GoldLight
    Draw-Line $b 3 12 2 14 $color.LeatherDark; Draw-Line $b 12 12 13 14 $color.LeatherDark
    Set-Pixel $b 7 10 $color.RedLight; Set-Pixel $b 8 10 $color.RedLight
    return $b
}

function New-HeatproofPannier {
    $b = New-Sprite
    Fill-Rect $b 1 5 6 8 $color.Outline; Fill-Rect $b 9 5 6 8 $color.Outline
    Fill-Rect $b 2 6 4 6 $color.NetheriteDark; Fill-Rect $b 10 6 4 6 $color.NetheriteDark
    Fill-Rect $b 6 4 4 7 $color.RedDark
    Set-Pixel $b 3 9 $color.Orange; Set-Pixel $b 4 10 $color.Yellow
    Set-Pixel $b 12 9 $color.Orange; Set-Pixel $b 11 10 $color.Yellow
    Fill-Rect $b 2 6 4 1 $color.Red; Fill-Rect $b 10 6 4 1 $color.Red
    return $b
}

function New-RamHeadpiece($dark, $mid, $light) {
    $b = New-Sprite
    Draw-Line $b 6 5 3 3 $color.Outline; Draw-Line $b 3 3 1 6 $color.Outline; Draw-Line $b 1 6 3 10 $color.Outline
    Draw-Line $b 9 5 12 3 $color.Outline; Draw-Line $b 12 3 14 6 $color.Outline; Draw-Line $b 14 6 12 10 $color.Outline
    Draw-Line $b 5 5 3 4 $mid; Draw-Line $b 3 4 2 6 $light; Draw-Line $b 2 6 4 9 $mid
    Draw-Line $b 10 5 12 4 $mid; Draw-Line $b 12 4 13 6 $light; Draw-Line $b 13 6 11 9 $mid
    Fill-Rect $b 5 5 6 7 $color.Outline
    Fill-Rect $b 6 6 4 5 $mid
    Fill-Rect $b 7 6 2 2 $light
    Fill-Rect $b 7 10 2 3 $dark
    return $b
}

function New-ImpactHarness {
    $b = New-Sprite
    Draw-Line $b 3 3 12 12 $color.LeatherDark; Draw-Line $b 12 3 3 12 $color.LeatherDark
    Fill-Rect $b 4 4 8 8 $color.Outline
    Fill-Rect $b 5 5 6 6 $color.GoldDark
    Fill-Rect $b 7 5 2 6 $color.GoldLight
    Fill-Rect $b 5 7 6 2 $color.GoldLight
    Set-Pixel $b 7 7 $color.IronLight; Set-Pixel $b 8 8 $color.Iron
    return $b
}

function New-EchoHarness {
    $b = New-Sprite
    Fill-Rect $b 2 5 12 6 $color.Outline
    Fill-Rect $b 3 6 10 4 $color.Aqua
    Fill-Rect $b 3 7 4 2 $color.AquaLight
    Set-Pixel $b 8 7 $color.IronLight
    Set-Pixel $b 10 6 $color.AquaLight; Set-Pixel $b 10 9 $color.AquaLight
    Set-Pixel $b 11 5 $color.AquaLight; Set-Pixel $b 11 10 $color.AquaLight
    Set-Pixel $b 12 4 $color.AquaLight; Set-Pixel $b 12 11 $color.AquaLight
    return $b
}

function New-ThermalJacket {
    $b = New-Sprite
    Fill-Rect $b 4 3 8 11 $color.Outline
    Fill-Rect $b 5 4 6 9 $color.Red
    Fill-Rect $b 1 5 4 6 $color.Outline; Fill-Rect $b 11 5 4 6 $color.Outline
    Fill-Rect $b 2 6 2 4 $color.RedDark; Fill-Rect $b 12 6 2 4 $color.RedDark
    Fill-Rect $b 7 4 2 9 $color.NetheriteDark
    Set-Pixel $b 6 9 $color.Orange; Set-Pixel $b 6 10 $color.Yellow
    Set-Pixel $b 9 8 $color.Yellow; Set-Pixel $b 9 9 $color.Orange
    return $b
}

function New-ExpeditionHarness {
    $b = New-Sprite
    Fill-Rect $b 3 3 10 11 $color.Outline
    Fill-Rect $b 4 4 8 9 $color.Green
    Fill-Rect $b 2 5 2 7 $color.LeatherDark; Fill-Rect $b 12 5 2 7 $color.LeatherDark
    Fill-Rect $b 6 6 4 4 $color.IronLight
    Set-Pixel $b 7 7 $color.Red; Set-Pixel $b 8 8 $color.Black
    Fill-Rect $b 5 11 6 2 $color.GreenDark
    Set-Pixel $b 5 4 $color.GreenLight
    return $b
}

function New-SeedPouch {
    $b = New-Sprite
    Draw-Line $b 8 4 6 1 $color.GreenDark; Draw-Line $b 8 4 10 1 $color.GreenDark
    Set-Pixel $b 5 1 $color.GreenLight; Set-Pixel $b 10 1 $color.GreenLight
    Fill-Rect $b 4 4 8 10 $color.Outline
    Fill-Rect $b 5 5 6 8 $color.Leather
    Fill-Rect $b 5 6 6 2 $color.GoldDark
    Set-Pixel $b 7 9 $color.GreenLight; Set-Pixel $b 9 10 $color.GreenDark
    Set-Pixel $b 6 11 $color.Page; Set-Pixel $b 8 12 $color.Page
    return $b
}

function New-CargoHitchingPost {
    $b = New-Sprite
    Fill-Rect $b 5 1 5 13 $color.Outline
    Fill-Rect $b 6 2 3 11 $color.Leather
    Fill-Rect $b 4 12 7 3 $color.IronDark
    Fill-Rect $b 5 12 5 2 $color.Iron
    Fill-Rect $b 6 2 3 2 $color.LeatherLight
    Draw-Line $b 9 5 13 6 $color.PageDark; Draw-Line $b 13 6 13 10 $color.PageDark
    Draw-Line $b 13 10 10 11 $color.PageDark
    Set-Pixel $b 9 6 $color.GoldDark
    return $b
}

function New-StatusIcon([string]$kind) {
    $b = New-Sprite
    switch ($kind) {
        'wolf_armor' {
            Fill-Rect $b 3 3 10 10 $color.Outline; Fill-Rect $b 4 4 8 8 $color.Iron
            Fill-Rect $b 6 3 4 4 $color.IronLight; Fill-Rect $b 7 8 2 5 $color.IronDark
        }
        'whitelist' {
            Fill-Rect $b 4 2 8 11 $color.Outline; Fill-Rect $b 5 3 6 8 $color.White
            Draw-Line $b 6 7 7 9 $color.Green; Draw-Line $b 7 9 10 5 $color.Green
        }
        'blacklist' {
            Fill-Rect $b 3 3 10 10 $color.RedDark; Fill-Rect $b 5 5 6 6 $color.Clear
            Fill-Rect $b 7 2 2 12 $color.RedLight; Fill-Rect $b 2 7 12 2 $color.RedLight
        }
        'enchanted_lapis' {
            Fill-Rect $b 3 2 10 12 $color.Outline; Fill-Rect $b 4 3 8 10 $color.LapisDark
            Fill-Rect $b 6 5 4 5 $color.Lapis; Set-Pixel $b 7 5 $color.LapisLight
            Fill-Rect $b 4 11 8 2 $color.Page
        }
        'enchanted_wolf' {
            Fill-Rect $b 3 2 10 12 $color.Outline; Fill-Rect $b 4 3 8 10 $color.RedDark
            Set-Pixel $b 6 6 $color.White; Set-Pixel $b 9 6 $color.White
            Fill-Rect $b 7 7 2 2 $color.IronLight; Fill-Rect $b 4 11 8 2 $color.Page
        }
        'enchanted_aquatic' {
            Fill-Rect $b 3 2 10 12 $color.Outline; Fill-Rect $b 4 3 8 10 $color.AquaDark
            Draw-Line $b 5 8 8 5 $color.AquaLight; Draw-Line $b 8 5 11 8 $color.AquaLight
            Fill-Rect $b 4 11 8 2 $color.Page
        }
        'bonded' {
            Set-Pixel $b 5 3 $color.RedLight; Set-Pixel $b 10 3 $color.RedLight
            Fill-Rect $b 4 4 8 3 $color.Red; Fill-Rect $b 5 7 6 2 $color.Red
            Fill-Rect $b 6 9 4 2 $color.RedDark; Fill-Rect $b 7 11 2 2 $color.RedDark
            Set-Pixel $b 6 6 $color.White; Set-Pixel $b 9 6 $color.White
            Fill-Rect $b 7 7 2 2 $color.White
        }
    }
    return $b
}

$sprites = [ordered]@{
    target_ledger = { New-TargetLedger }
    spiked_collar = { New-SpikedCollar }
    pet_satchel = { New-PetSatchel }
    axolotl_harness = { New-AxolotlHarness }
    lapis_talisman = { New-LapisTalisman }
    iron_moonfang_blade = { New-MoonfangBlade $color.IronDark $color.Iron $color.IronLight }
    gold_moonfang_blade = { New-MoonfangBlade $color.GoldDark $color.Gold $color.GoldLight }
    diamond_moonfang_blade = { New-MoonfangBlade $color.DiamondDark $color.Diamond $color.DiamondLight }
    netherite_moonfang_blade = { New-MoonfangBlade $color.NetheriteDark $color.Netherite $color.NetheriteLight }
    control_core = { New-ControlCore }
    leather_reinforcement = { New-Reinforcement $color.LeatherDark $color.Leather $color.LeatherLight }
    iron_reinforcement = { New-Reinforcement $color.IronDark $color.Iron $color.IronLight }
    diamond_reinforcement = { New-Reinforcement $color.DiamondDark $color.Diamond $color.DiamondLight }
    netherite_reinforcement = { New-Reinforcement $color.NetheriteDark $color.Netherite $color.NetheriteLight }
    horse_pack_chest = { New-HorsePackChest }
    donkey_pack_frame = { New-DonkeyPackFrame }
    mule_sorting_pannier = { New-MuleSortingPannier }
    camel_caravan_rack = { New-CamelCaravanRack }
    heatproof_pannier = { New-HeatproofPannier }
    iron_ram_headpiece = { New-RamHeadpiece $color.IronDark $color.Iron $color.IronLight }
    diamond_ram_headpiece = { New-RamHeadpiece $color.DiamondDark $color.Diamond $color.DiamondLight }
    netherite_ram_headpiece = { New-RamHeadpiece $color.NetheriteDark $color.Netherite $color.NetheriteLight }
    impact_harness = { New-ImpactHarness }
    echo_harness = { New-EchoHarness }
    thermal_jacket = { New-ThermalJacket }
    expedition_harness = { New-ExpeditionHarness }
    seed_pouch = { New-SeedPouch }
    cargo_hitching_post = { New-CargoHitchingPost }
}

foreach ($entry in $sprites.GetEnumerator()) {
    Save-Sprite $itemDirectory $entry.Key (& $entry.Value)
}

$guiSprites = [ordered]@{
    wolf_armor = 'wolf_armor'
    whitelist = 'whitelist'
    blacklist = 'blacklist'
    enchanted_lapis = 'enchanted_lapis'
    enchanted_wolf = 'enchanted_wolf'
    enchanted_aquatic = 'enchanted_aquatic'
    bonded = 'bonded'
}
foreach ($entry in $guiSprites.GetEnumerator()) {
    Save-Sprite $guiDirectory $entry.Key (New-StatusIcon $entry.Value)
}

$allPreviewSprites = [ordered]@{}
foreach ($entry in $sprites.GetEnumerator()) { $allPreviewSprites[$entry.Key] = Join-Path $itemDirectory ($entry.Key + '.png') }
foreach ($entry in $guiSprites.GetEnumerator()) { $allPreviewSprites[('gui_' + $entry.Key)] = Join-Path $guiDirectory ($entry.Key + '.png') }

$columns = 7
$cellWidth = 112
$cellHeight = 90
$rows = [Math]::Ceiling($allPreviewSprites.Count / [double]$columns)
$preview = [System.Drawing.Bitmap]::new($columns * $cellWidth, $rows * $cellHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($preview)
try {
    $graphics.Clear((New-Color '#242424'))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $font = [System.Drawing.Font]::new('Segoe UI', 8)
    $brush = [System.Drawing.SolidBrush]::new((New-Color '#E6E6E6'))
    try {
        $index = 0
        foreach ($entry in $allPreviewSprites.GetEnumerator()) {
            $column = $index % $columns
            $row = [Math]::Floor($index / $columns)
            $x = $column * $cellWidth
            $y = $row * $cellHeight
            $sprite = [System.Drawing.Bitmap]::new($entry.Value)
            try {
                $graphics.DrawImage($sprite, [System.Drawing.Rectangle]::new($x + 24, $y + 4, 64, 64))
            }
            finally {
                $sprite.Dispose()
            }
            $graphics.DrawString($entry.Key, $font, $brush, [System.Drawing.RectangleF]::new($x + 2, $y + 70, $cellWidth - 4, 18))
            $index++
        }
    }
    finally {
        $font.Dispose()
        $brush.Dispose()
    }
    $preview.Save((Join-Path $previewDirectory 'handcrafted_item_textures.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
    $graphics.Dispose()
    $preview.Dispose()
}

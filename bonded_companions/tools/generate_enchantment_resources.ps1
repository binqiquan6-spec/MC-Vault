param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot
)

$definitions = @(
    @{ Id = 'loyal_guard'; Max = 3; Group = 'wolf_armor'; Exclusive = 'wolf_guard' },
    @{ Id = 'pursuit'; Max = 2; Group = 'wolf_armor' },
    @{ Id = 'last_stand'; Max = 1; Group = 'wolf_armor'; Treasure = $true; Exclusive = 'wolf_guard' },
    @{ Id = 'moist_gills'; Max = 3; Group = 'axolotl_harness' },
    @{ Id = 'currentbound'; Max = 3; Group = 'axolotl_harness' },
    @{ Id = 'symbiotic_echo'; Max = 2; Group = 'axolotl_harness'; Treasure = $true },
    @{ Id = 'ambush'; Max = 3; Group = 'moonfang_blades' },
    @{ Id = 'scent_pursuit'; Max = 2; Group = 'moonfang_blades' },
    @{ Id = 'lifebite'; Max = 2; Group = 'moonfang_blades' },
    @{ Id = 'lightfoot'; Max = 3; Group = 'lapis_talisman' },
    @{ Id = 'calamity_ward'; Max = 2; Group = 'lapis_talisman' },
    @{ Id = 'spirit_breath'; Max = 3; Group = 'lapis_talisman' },
    @{ Id = 'soul_recall'; Max = 1; Group = 'lapis_talisman'; Treasure = $true },
    @{ Id = 'fortress'; Max = 3; Group = 'reinforcements'; Exclusive = 'golem_defense' },
    @{ Id = 'charged_blow'; Max = 2; Group = 'reinforcements' },
    @{ Id = 'reactive_plating'; Max = 2; Group = 'reinforcements'; Exclusive = 'golem_defense' },
    @{ Id = 'ember_snow'; Max = 3; Group = 'reinforcements'; Exclusive = 'snow_projectile' },
    @{ Id = 'deep_freeze'; Max = 3; Group = 'reinforcements'; Exclusive = 'snow_projectile' },
    @{ Id = 'rapid_volley'; Max = 2; Group = 'reinforcements' },
    @{ Id = 'surefooted'; Max = 3; Group = 'horse_armor' },
    @{ Id = 'rider_shield'; Max = 2; Group = 'horse_armor'; Exclusive = 'horse_projectile' },
    @{ Id = 'vital_plating'; Max = 3; Group = 'horse_armor' },
    @{ Id = 'break_formation'; Max = 3; Group = 'ram_headpieces' },
    @{ Id = 'regain_momentum'; Max = 2; Group = 'ram_headpieces' },
    @{ Id = 'concussion'; Max = 2; Group = 'ram_headpieces' },
    @{ Id = 'breakwater'; Max = 3; Group = 'echo_harness' },
    @{ Id = 'echo_lock'; Max = 2; Group = 'echo_harness' },
    @{ Id = 'cooperative_hunt'; Max = 2; Group = 'echo_harness' },
    @{ Id = 'rescue_instinct'; Max = 1; Group = 'echo_harness' },
    @{ Id = 'moisture_guard'; Max = 2; Group = 'thermal_jacket' },
    @{ Id = 'heatstride'; Max = 2; Group = 'thermal_jacket' }
)

$itemTags = [ordered]@{
    wolf_armor = @('minecraft:wolf_armor')
    axolotl_harness = @('bonded_companions:axolotl_harness')
    moonfang_blades = @(
        'bonded_companions:iron_moonfang_blade',
        'bonded_companions:gold_moonfang_blade',
        'bonded_companions:diamond_moonfang_blade',
        'bonded_companions:netherite_moonfang_blade'
    )
    lapis_talisman = @('bonded_companions:lapis_talisman')
    reinforcements = @(
        'bonded_companions:leather_reinforcement',
        'bonded_companions:iron_reinforcement',
        'bonded_companions:diamond_reinforcement',
        'bonded_companions:netherite_reinforcement'
    )
    horse_armor = @(
        'minecraft:leather_horse_armor',
        'minecraft:iron_horse_armor',
        'minecraft:golden_horse_armor',
        'minecraft:diamond_horse_armor'
    )
    ram_headpieces = @(
        'bonded_companions:iron_ram_headpiece',
        'bonded_companions:diamond_ram_headpiece',
        'bonded_companions:netherite_ram_headpiece'
    )
    echo_harness = @('bonded_companions:echo_harness')
    thermal_jacket = @('bonded_companions:thermal_jacket')
}

$dataRoot = Join-Path $ProjectRoot 'src/main/resources/data'
$enchantmentDirectory = Join-Path $dataRoot 'bonded_companions/enchantment'
$itemTagDirectory = Join-Path $dataRoot 'bonded_companions/tags/item/enchantable'
$exclusiveDirectory = Join-Path $dataRoot 'bonded_companions/tags/enchantment/exclusive_set'
$minecraftTagDirectory = Join-Path $dataRoot 'minecraft/tags/enchantment'
New-Item -ItemType Directory -Force -Path $enchantmentDirectory, $itemTagDirectory, $exclusiveDirectory, $minecraftTagDirectory | Out-Null

function Write-Json([string]$path, $value) {
    $value | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $path -Encoding utf8NoBOM
}

foreach ($definition in $definitions) {
    $treasure = $definition.ContainsKey('Treasure') -and $definition.Treasure
    $json = [ordered]@{
        anvil_cost = if ($treasure) { 8 } else { 4 }
        description = [ordered]@{ translate = "enchantment.bonded_companions.$($definition.Id)" }
        effects = [ordered]@{}
        max_cost = [ordered]@{ base = if ($treasure) { 75 } else { 40 }; per_level_above_first = 15 }
        max_level = $definition.Max
        min_cost = [ordered]@{ base = if ($treasure) { 25 } else { 10 }; per_level_above_first = 10 }
        slots = @('any')
        supported_items = "#bonded_companions:enchantable/$($definition.Group)"
        weight = if ($treasure) { 1 } else { 5 }
    }
    if (-not $treasure) {
        $json.primary_items = "#bonded_companions:enchantable/$($definition.Group)"
    }
    if ($definition.ContainsKey('Exclusive')) {
        $json.exclusive_set = "#bonded_companions:exclusive_set/$($definition.Exclusive)"
    }
    Write-Json (Join-Path $enchantmentDirectory ($definition.Id + '.json')) $json
}

foreach ($tag in $itemTags.GetEnumerator()) {
    Write-Json (Join-Path $itemTagDirectory ($tag.Key + '.json')) ([ordered]@{ replace = $false; values = $tag.Value })
}

$exclusiveTags = [ordered]@{
    wolf_guard = @('bonded_companions:loyal_guard', 'bonded_companions:last_stand')
    golem_defense = @('bonded_companions:fortress', 'bonded_companions:reactive_plating')
    snow_projectile = @('bonded_companions:ember_snow', 'bonded_companions:deep_freeze')
    horse_projectile = @('minecraft:projectile_protection', 'bonded_companions:rider_shield')
}
foreach ($tag in $exclusiveTags.GetEnumerator()) {
    Write-Json (Join-Path $exclusiveDirectory ($tag.Key + '.json')) ([ordered]@{ replace = $false; values = $tag.Value })
}

$normalEnchantments = @($definitions | Where-Object { -not ($_.ContainsKey('Treasure') -and $_.Treasure) } |
    ForEach-Object { "bonded_companions:$($_.Id)" })
$treasureEnchantments = @($definitions | Where-Object { $_.ContainsKey('Treasure') -and $_.Treasure } |
    ForEach-Object { "bonded_companions:$($_.Id)" })
Write-Json (Join-Path $minecraftTagDirectory 'non_treasure.json') ([ordered]@{ replace = $false; values = $normalEnchantments })
Write-Json (Join-Path $minecraftTagDirectory 'treasure.json') ([ordered]@{ replace = $false; values = $treasureEnchantments })

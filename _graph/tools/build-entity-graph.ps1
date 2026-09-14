[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$graphRoot = Split-Path -Parent $PSScriptRoot
$entityRoot = Join-Path $graphRoot 'entities'
$categoryMap = [ordered]@{
    '生物' = 'creature'
    '物品' = 'item'
    '附魔' = 'enchantment'
    '系统' = 'system'
}

function Parse-EntityRows {
    param(
        [Parameter(Mandatory)] [string] $Category,
        [Parameter(Mandatory)] [string] $Rows
    )

    $entities = @()
    foreach ($line in ($Rows -split "`r?`n")) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
            continue
        }

        $parts = $line.Split('|', 8)
        if ($parts.Count -ne 8) {
            throw "Invalid $Category row: $line"
        }

        $entities += [pscustomobject]@{
            Category = $Category
            Name = $parts[0].Trim()
            RegistryId = $parts[1].Trim()
            Status = $parts[2].Trim()
            Summary = $parts[3].Trim()
            Attributes = @($parts[4].Split('~') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            Functions = @($parts[5].Split('~') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            Relations = @($parts[6].Split('~') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            Sources = @($parts[7].Split('~') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        }
    }

    return $entities
}

function Format-YamlValue {
    param([string] $Value)
    return '"' + $Value.Replace('"', '\"') + '"'
}

function Write-EntityNote {
    param([Parameter(Mandatory)] $Entity)

    $categoryFolder = Join-Path $entityRoot $Entity.Category
    $outputPath = Join-Path $categoryFolder ($Entity.Name + '.md')
    $resolvedGraphRoot = [IO.Path]::GetFullPath($graphRoot)
    $resolvedOutputPath = [IO.Path]::GetFullPath($outputPath)
    if (-not $resolvedOutputPath.StartsWith($resolvedGraphRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to write outside graph root: $resolvedOutputPath"
    }

    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add('---')
    $lines.Add("graph_entity: $($categoryMap[$Entity.Category])")
    $lines.Add('project: bonded_companions')
    if ($Entity.RegistryId -and $Entity.RegistryId -ne '-') {
        $lines.Add('registry_id: ' + (Format-YamlValue $Entity.RegistryId))
    }
    $lines.Add('implementation: ' + (Format-YamlValue $Entity.Status))
    $lines.Add('generated: true')
    $lines.Add('---')
    $lines.Add('')
    $lines.Add("# $($Entity.Name)")
    $lines.Add('')
    $lines.Add('> [!info] 关系节点')
    $lines.Add('> 本页由关系图生成器维护，只用于导航和解释关系；原始规格与代码仍是事实来源。')
    $lines.Add('')
    $lines.Add($Entity.Summary)
    $lines.Add('')
    $lines.Add('## 导航')
    $lines.Add('')
    $lines.Add('- 总目录：[[_graph/MC 项目总览|MC 项目总览]]')
    $lines.Add('- 项目：[[_graph/Bonded Companions|Bonded Companions]]')
    $lines.Add('- 实体索引：[[_graph/entities/Bonded Companions 实体索引|实体索引]]')
    $lines.Add('')
    $lines.Add('## 当前状态')
    $lines.Add('')
    $lines.Add("- $($Entity.Status)")
    $lines.Add('')
    $lines.Add('## 属性')
    $lines.Add('')
    foreach ($attribute in $Entity.Attributes) {
        $lines.Add("- $attribute")
    }
    $lines.Add('')
    $lines.Add('## 能力与功能')
    $lines.Add('')
    foreach ($function in $Entity.Functions) {
        $lines.Add("- $function")
    }
    $lines.Add('')
    $lines.Add('## 关系')
    $lines.Add('')
    foreach ($relation in $Entity.Relations) {
        $pair = $relation.Split('=', 2)
        if ($pair.Count -ne 2) {
            throw "Invalid relation '$relation' in $($Entity.Name)"
        }
        $targetCategory = $pair[0].Trim()
        $targetName = $pair[1].Trim()
        $lines.Add("- $targetCategory：[[_graph/entities/$targetCategory/$targetName|$targetName]]")
    }
    $lines.Add('')
    $lines.Add('## 依据')
    $lines.Add('')
    foreach ($source in ($Entity.Sources | Where-Object { $_ -match 'PRD|RECIPES|Tech-Spec|宝藏来源|原版' })) {
        $lines.Add("- $source")
    }
    $lines.Add("- IMPLEMENTATION-STATUS（2026-09-14）：$($Entity.Status)")

    Set-Content -LiteralPath $outputPath -Value ($lines -join "`n") -Encoding utf8
}

$creatureRows = @'
狼|minecraft:wolf|prototype / complete species mechanics p0-pending|近战护卫与追猎伙伴。|身份：原版骨头驯服~栏位：名单、带刺项圈、原版狼铠、收纳袋~模式：跟随、等待~名单：支持|跟随并防卫主人~依据白名单与黑名单选择合法目标~可用狼铠、项圈与收纳袋形成防护、反伤和携带组合|物品=目标名单册~物品=带刺项圈~物品=原版狼铠~物品=宠物收纳袋~附魔=忠卫~附魔=追猎~附魔=不屈~系统=目标名单系统~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=持久化与死亡掉落|PRD §3.1、§5、§6~IMPLEMENTATION-STATUS：基础归属、栏位与目标策略已实现；完整物种机制待完成
美西螈|minecraft:axolotl|prototype / hydration and enchantment effects p0-pending|水下协同伙伴。|缔结：生热带鱼普通右击，默认 1/3~栏位：名单、美西螈背带~名单：支持~背带基础：+2 护甲|在水中跟随与协同作战~缺水安全行为高于攻击~装桶、放出、跨维度与重载应保留归属、装备和冷却|物品=目标名单册~物品=美西螈背带~附魔=润腮~附魔=逐流~附魔=共生回响~系统=目标名单系统~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=持久化与死亡掉落|PRD §3.1、§7~IMPLEMENTATION-STATUS：基础缔结存在；水生能力与装桶闭环待完成
狐狸|minecraft:fox|prototype / complete fox mechanics p0-pending|机动武器伙伴。|缔结：生鸡肉普通右击，默认 1/3~最大生命：16（测试基线）~栏位：名单、真实主手狐衔、青金护符、收纳袋~模式：跟随、等待|归属后停止逃避主人和默认捕猎~普通武器按完整正常伤害 D×0.5~重锤按 D×0.7 且最终移速×0.7~衔月刃使用材料专属加值|物品=目标名单册~物品=普通狐衔武器~物品=原版重锤~物品=铁制衔月刃~物品=金制衔月刃~物品=钻石衔月刃~物品=下界合金衔月刃~物品=青金护符~物品=宠物收纳袋~附魔=伏袭~附魔=追香~附魔=噬生~附魔=轻足~附魔=避祸~附魔=灵息~附魔=归魂~系统=目标名单系统~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=持久化与死亡掉落|PRD §3.1、§8~IMPLEMENTATION-STATUS：武器伤害分类已实现；完整狐狸能力待完成
雪傀儡|minecraft:snow_golem|prototype / area, reinforcement, projectile effects p0-pending|范围远程守卫。|绑定：装入控制核心~栏位：名单、控制核心、雪傀儡专用补强~模式：守卫、跟随、待命~普通雪球对合法目标基础伤害：1|在活动区内远程守卫~控制核心管理中心、半径和模式~补强提高生命、护甲并降低环境熔化伤害|物品=目标名单册~物品=控制核心~物品=雪傀儡保温皮套~物品=雪傀儡铁制护架~物品=雪傀儡钻石凝霜甲片~物品=雪傀儡下界合金熔芯甲片~附魔=烬雪~附魔=深寒~附魔=连射~系统=目标名单系统~系统=傀儡活动区与控制核心~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §9~当前物品与配方资源已拆分；完整傀儡行为待完成
铁傀儡|minecraft:iron_golem|prototype / area and reinforcement effects p0-pending|范围重装近战守卫。|绑定：仅玩家建造个体可用控制核心绑定~栏位：名单、控制核心、铁傀儡专用补强~模式：守卫、跟随、待命~额外减伤总上限：40%|在活动区内巡查、选敌并返回中心~控制核心管理中心、半径和模式~补强提供护甲、韧性与剩余伤害减免，不提供抗击退|物品=目标名单册~物品=控制核心~物品=铁傀儡皮革缓冲层~物品=铁傀儡铁质补强板~物品=铁傀儡钻石强化板~物品=铁傀儡下界合金强化板~附魔=堡垒~附魔=蓄势重击~附魔=应激甲片~系统=目标名单系统~系统=傀儡活动区与控制核心~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §9~当前物品与配方资源已拆分；完整傀儡行为待完成
山羊|minecraft:goat|prototype / ram mechanics p0-pending|冲撞破阵伙伴。|缔结：苹果普通右击，默认 1/3~栏位：名单、冲角、缓冲背带~普通山羊冲撞冷却：约 10 秒~尖叫山羊冲撞冷却：约 7 秒|主要攻击保持冲撞，不转为持续近战~只冲撞合法黑名单目标~冲刺前检查落差、岩浆、路径和友方遮挡~冲撞不破坏方块|物品=目标名单册~物品=铁冲角~物品=钻石冲角~物品=下界合金冲角~物品=缓冲背带~附魔=破阵~附魔=回势~附魔=震荡~系统=目标名单系统~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=装备与附魔生命周期|PRD §12~IMPLEMENTATION-STATUS：基础缔结存在；冲撞机制待完成
海豚|minecraft:dolphin|prototype / aquatic combat and rescue p0-pending|水下追踪与救援伙伴。|缔结：热带鱼普通右击，默认 1/3~栏位：名单、回声背带~名单：支持~背带基础：+2 护甲|只选择水中可达目标~空气低于阈值时强制上浮~不传送、不在陆地持续寻路~通过背带附魔获得追踪、协猎和救援能力|物品=目标名单册~物品=回声背带~附魔=破浪~附魔=回声锁定~附魔=协猎~附魔=救援本能~系统=目标名单系统~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=持久化与死亡掉落|PRD §13~IMPLEMENTATION-STATUS：基础缔结存在；水下能力待完成
马|minecraft:horse|prototype cargo / safe saddle integration p0-pending|18 格专职运输坐骑。|身份：原版驯服~名单：不支持~货运：马用驮箱 18 格~防具：原版马铠|驮箱占用鞍位并使马完全不可骑乘~保留原版马铠位~只有上背驮箱命中区打开货仓~可经货运拴桩接入自动化|物品=马用驮箱~物品=原版马铠~物品=原版鞍~附魔=稳蹄~附魔=骑手之盾~附魔=生命甲片~系统=货运与拴桩自动化~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §10、§11~IMPLEMENTATION-STATUS：基础货运和禁骑已实现；真实鞍位与命中区待完成
驴|minecraft:donkey|prototype cargo / safe install and hit region p0-pending|27 格大宗运输坐骑。|身份：原版驯服~名单：不支持~货运：驴用驮架 27 格~骑乘：保留|不能与原版箱子并存~通过可见驮具命中区开仓~可经货运拴桩接入自动化|物品=驴用驮架~物品=原版鞍~系统=货运与拴桩自动化~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §10~IMPLEMENTATION-STATUS：基础货运已实现；安全安装与命中区待完成
骡|minecraft:mule|prototype cargo / safe install and hit region p0-pending|带过滤器的物流运输坐骑。|身份：原版驯服~名单：不支持~货运：18 格~过滤：3 个幽灵过滤位~骑乘：保留|自动输入只接受符合任一过滤器的物品~过滤器全空时接受所有物品~手动页面不受错误过滤锁死~可经货运拴桩接入自动化|物品=骡用分拣驮袋~物品=原版鞍~系统=货运与拴桩自动化~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §10~IMPLEMENTATION-STATUS：容量与过滤基础已实现；完整页面和命中区待完成
骆驼|minecraft:camel|prototype cargo / safe install and hit region p0-pending|36 格长途运输坐骑。|身份：原版驯服~名单：不支持~货运：骆驼商旅架 36 格~乘客：安装后保留 1 个座位|提供本模组最大货运容量~安装商旅架后停用第二乘客位~通过可见驮具命中区开仓~可经货运拴桩接入自动化|物品=骆驼商旅架~物品=原版鞍~系统=货运与拴桩自动化~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §10~IMPLEMENTATION-STATUS：基础货运和第二座位限制已实现；完整安装与命中区待完成
炽足兽|minecraft:strider|prototype / jacket and Heatstride gameplay p0-pending|岩浆与陆地两栖运输伙伴。|缔结：绯红菌普通右击，默认 1/3~名单：不支持~栏位：鞍、热力皮夹、耐热驮袋~货运：18 格|热力皮夹取消干燥陆地发冷和减速~耐热驮袋保护物品实体与内容免于焚毁~雨、水与浸水伤害不会被基础皮夹免疫|物品=原版鞍~物品=热力皮夹~物品=耐热驮袋~附魔=避湿~附魔=热行~系统=货运与拴桩自动化~系统=缔结与管理~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §14~IMPLEMENTATION-STATUS：基础缔结与货运存在；皮夹和热行尚未完整接入
嗅探兽|minecraft:sniffer|prototype / seed routing p0-pending|非战斗探索与种子收集伙伴。|缔结：瓶子草荚果普通右击，测试基线必定成功~名单：不支持~栏位：远行背带、种子袋~模式：跟随、搜寻、待命|原版挖掘产物优先进入种子袋~袋满后才掉落到世界~不增加原版嗅探之外的方块破坏|物品=远行背带~物品=种子袋~系统=伙伴模式与安全优先级~系统=缔结与管理~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §15~IMPLEMENTATION-STATUS：基础缔结存在；种子路由待完成
'@

$itemRows = @'
目标名单册|bonded_companions:target_ledger|prototype core behavior implemented|可携带的目标规则容器。|耐久：无~数据：白名单、黑名单、默认黑名单开关、记录模式、显示名称快照~记录身份：玩家 UUID、生物注册 ID、命名实体 UUID|装备后启用伙伴主动名单控制~白名单绝对优先~手持右击记录实体，右击空气切换模式|生物=狼~生物=美西螈~生物=狐狸~生物=雪傀儡~生物=铁傀儡~生物=山羊~生物=海豚~系统=目标名单系统~系统=持久化与死亡掉落|PRD §5~RECIPES §2.1~目标规则 codec 与核心优先级已实现
带刺项圈|bonded_companions:spiked_collar|registered / complete thorns behavior p0-pending|狼用反伤装备。|耐久：256~修理：铁锭，每个恢复最大耐久 25%~基础效果：等效荆棘 I~兼容：荆棘、耐久、经验修补、消失诅咒|成功反伤时损失 1 耐久~主人、白名单对象与抚摸动作不触发反伤~荆棘 II/III 替换基础下限而非叠加|生物=狼~系统=目标名单系统~系统=装备与附魔生命周期|PRD §6.2、§16~RECIPES §2.2~物品已注册；完整能力待实现
宠物收纳袋|bonded_companions:pet_satchel|prototype cargo implemented|狼和狐狸使用的随身容器。|容量：9 格~耐久：无~内容保存在物品数据组件~嵌套货运容器：禁止|拆下后保留内容~生物死亡时连同内容作为一个物品掉落~有内容时不能作为耐热驮袋材料|生物=狼~生物=狐狸~系统=持久化与死亡掉落~系统=货运与拴桩自动化|PRD §6.1、§8.2、§10.1~RECIPES §2.3~基础便携货运已实现
美西螈背带|bonded_companions:axolotl_harness|registered / complete effects p0-pending|美西螈专用水生防护装备。|护甲：+2~耐久：192~修理：海晶碎片~兼容原版：保护、弹射物保护、耐久、经验修补、消失诅咒|承载离水耐受、水中速度和共生治疗附魔~不接受水下速掘、深海探索者、水下呼吸|生物=美西螈~附魔=润腮~附魔=逐流~附魔=共生回响~系统=装备与附魔生命周期|PRD §7.2、§7.3~RECIPES §2.4~物品已注册；完整效果待实现
青金护符|bonded_companions:lapis_talisman|registered / talisman effects p0-pending|狐狸专属防护与保命护符。|护甲：+2~耐久：256~修理：青金石~不接受原版附魔~最多同时拥有 4 种专属附魔|承载减摔落、减爆炸、脱战恢复与致命保护能力|生物=狐狸~附魔=轻足~附魔=避祸~附魔=灵息~附魔=归魂~系统=装备与附魔生命周期|PRD §8.6~RECIPES §2.5~物品已注册；护符效果待实现
铁制衔月刃|bonded_companions:iron_moonfang_blade|prototype damage category implemented|狐狸专用铁质短刃。|耐久：175~玩家攻击加值：+3~狐狸攻击加值：+3~玩家攻击速度修正：-2.4~修理：铁锭|狐狸使用时不套用普通武器 D×0.5 惩罚~可承载狐狸专属武器附魔~狐狸嘴中禁用直接增伤类原版附魔|生物=狐狸~附魔=伏袭~附魔=追香~附魔=噬生~系统=装备与附魔生命周期|PRD §8.5~RECIPES §3.1~伤害类别已实现；附魔效果待完成
金制衔月刃|bonded_companions:gold_moonfang_blade|prototype damage category implemented|狐狸专用金质短刃。|耐久：22~玩家攻击加值：+3~狐狸攻击加值：+4~玩家攻击速度修正：-2.4~修理：金锭|狐狸使用时不套用普通武器 D×0.5 惩罚~可承载狐狸专属武器附魔~狐狸嘴中禁用直接增伤类原版附魔|生物=狐狸~附魔=伏袭~附魔=追香~附魔=噬生~系统=装备与附魔生命周期|PRD §8.5~RECIPES §3.1~伤害类别已实现；附魔效果待完成
钻石衔月刃|bonded_companions:diamond_moonfang_blade|prototype damage category implemented|狐狸专用钻石短刃。|耐久：1093~玩家攻击加值：+3~狐狸攻击加值：+5.5~玩家攻击速度修正：-2.4~修理：钻石|狐狸使用时不套用普通武器 D×0.5 惩罚~可承载狐狸专属武器附魔~狐狸嘴中禁用直接增伤类原版附魔|生物=狐狸~附魔=伏袭~附魔=追香~附魔=噬生~系统=装备与附魔生命周期|PRD §8.5~RECIPES §3.1~伤害类别已实现；附魔效果待完成
下界合金衔月刃|bonded_companions:netherite_moonfang_blade|prototype damage category implemented|狐狸专用下界合金短刃。|耐久：1422~玩家攻击加值：+3~狐狸攻击加值：+7~玩家攻击速度修正：-2.4~修理：下界合金锭~物品耐火|狐狸使用时不套用普通武器 D×0.5 惩罚~由钻石衔月刃锻造升级并保留组件~狐狸嘴中禁用直接增伤类原版附魔|生物=狐狸~附魔=伏袭~附魔=追香~附魔=噬生~系统=装备与附魔生命周期|PRD §8.5~RECIPES §3.2~伤害类别已实现；附魔效果待完成
控制核心|bonded_companions:control_core|prototype binding and persistence implemented|傀儡绑定、范围与模式的数据核心。|耐久：无~保存：主人、绑定傀儡 UUID、中心维度与坐标、活动半径、模式~半径：8/16/24/32/48，默认 16~同一核心只绑定一只存活傀儡|初次普通右击绑定合格傀儡~控制守卫、跟随、待命模式~移除后傀儡待命但名单和补强保留|生物=雪傀儡~生物=铁傀儡~系统=傀儡活动区与控制核心~系统=持久化与死亡掉落|PRD §9.2~RECIPES §4.1~绑定与数据组件已实现；完整活动区行为待完成
雪傀儡保温皮套|bonded_companions:snow_golem_leather_wrap|registered / reinforcement effects p0-pending|雪傀儡皮革级补强。|耐久：256~最大生命：8~护甲：+2~环境熔化伤害降低：25%~修理：皮革|提供入门保温与防护~只可装备于雪傀儡，不能与铁傀儡补强交叉|生物=雪傀儡~附魔=烬雪~附魔=深寒~附魔=连射~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
雪傀儡铁制护架|bonded_companions:snow_golem_iron_brace|registered / reinforcement effects p0-pending|雪傀儡铁级补强。|耐久：512~最大生命：12~护甲：+4~环境熔化伤害降低：50%~修理：铁锭|从保温皮套升级~只可装备于雪傀儡，不能与铁傀儡补强交叉|生物=雪傀儡~附魔=烬雪~附魔=深寒~附魔=连射~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
雪傀儡钻石凝霜甲片|bonded_companions:snow_golem_diamond_frost_plate|registered / reinforcement effects p0-pending|雪傀儡钻石级补强。|耐久：1024~最大生命：16~护甲：+6~韧性：+1~环境熔化伤害降低：75%~修理：钻石|从铁制护架升级~只可装备于雪傀儡，不能与铁傀儡补强交叉|生物=雪傀儡~附魔=烬雪~附魔=深寒~附魔=连射~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
雪傀儡下界合金熔芯甲片|bonded_companions:snow_golem_netherite_core_plate|registered / reinforcement effects p0-pending|雪傀儡下界合金级补强。|耐久：1536~最大生命：20~护甲：+8~韧性：+2~环境熔化伤害降低：90%~修理：下界合金锭~物品耐火|由钻石凝霜甲片锻造升级~熔化减免不等于火焰或岩浆免疫|生物=雪傀儡~附魔=烬雪~附魔=深寒~附魔=连射~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
铁傀儡皮革缓冲层|bonded_companions:iron_golem_leather_padding|registered / reinforcement effects p0-pending|铁傀儡皮革级补强。|耐久：256~护甲：+2~剩余伤害再降低：5%~修理：皮革|提供局部缓冲和入门减伤~只可装备于铁傀儡，不能与雪傀儡补强交叉|生物=铁傀儡~附魔=堡垒~附魔=蓄势重击~附魔=应激甲片~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
铁傀儡铁质补强板|bonded_companions:iron_golem_iron_reinforcement|registered / reinforcement effects p0-pending|铁傀儡铁级补强。|耐久：512~护甲：+4~剩余伤害再降低：10%~修理：铁锭|从皮革缓冲层升级~提供伤害减免而非抗击退|生物=铁傀儡~附魔=堡垒~附魔=蓄势重击~附魔=应激甲片~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
铁傀儡钻石强化板|bonded_companions:iron_golem_diamond_reinforcement|registered / reinforcement effects p0-pending|铁傀儡钻石级补强。|耐久：1024~护甲：+6~韧性：+1~剩余伤害再降低：15%~修理：钻石|从铁质补强板升级~所有本模组额外减伤合计最高 40%|生物=铁傀儡~附魔=堡垒~附魔=蓄势重击~附魔=应激甲片~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
铁傀儡下界合金强化板|bonded_companions:iron_golem_netherite_reinforcement|registered / reinforcement effects p0-pending|铁傀儡下界合金级补强。|耐久：1536~护甲：+8~韧性：+2~剩余伤害再降低：20%~修理：下界合金锭~物品耐火|由钻石强化板锻造升级~所有本模组额外减伤合计最高 40%|生物=铁傀儡~附魔=堡垒~附魔=蓄势重击~附魔=应激甲片~系统=装备与附魔生命周期|PRD §9.3~RECIPES §4：对应物种专用配方与升级链已同步
马用驮箱|bonded_companions:horse_pack_chest|prototype cargo implemented / saddle boundary p0-pending|把马转为专职运输单位的货箱。|容量：18 格~耐久：无~占用：原版鞍位~嵌套货运容器：禁止|安装后马完全不可骑乘~保留马铠位~内容随物品保存并可由货运拴桩代理|生物=马~物品=原版鞍~系统=货运与拴桩自动化~系统=持久化与死亡掉落|PRD §10.2~RECIPES §5.1~容量与禁骑已实现；真实鞍位和安全拆装待完成
驴用驮架|bonded_companions:donkey_pack_frame|prototype cargo implemented / install flow p0-pending|驴用大宗运输货架。|容量：27 格~耐久：无~骑乘：保留~不能与原版箱子并存|内容随物品保存~通过货运拴桩代理给漏斗与 Create 物流|生物=驴~系统=货运与拴桩自动化~系统=持久化与死亡掉落|PRD §10.2~RECIPES §5.2~基础容量已实现；完整安装与命中区待完成
骡用分拣驮袋|bonded_companions:mule_sorting_pannier|prototype cargo and filters implemented|骡用过滤货袋。|容量：18 格~过滤：3 个不存物品的幽灵位~耐久：无~骑乘：保留|自动输入按三个过滤样本匹配~过滤全空时接受所有物品~手动存取不被过滤器阻止|生物=骡~系统=货运与拴桩自动化~系统=持久化与死亡掉落|PRD §10.2~RECIPES §5.3~容量与插入过滤基础已实现
骆驼商旅架|bonded_companions:camel_caravan_rack|prototype cargo implemented / install flow p0-pending|骆驼用长途大容量货架。|容量：36 格~耐久：无~骑乘：保留~乘客：安装后仅 1 人|停用骆驼第二乘客位~内容随物品保存~可由货运拴桩代理|生物=骆驼~系统=货运与拴桩自动化~系统=持久化与死亡掉落|PRD §10.2~RECIPES §5.4~容量与乘客限制已实现；完整安装与命中区待完成
耐热驮袋|bonded_companions:heatproof_pannier|prototype cargo implemented / recipe guard p0-pending|炽足兽用耐火货运容器。|容量：18 格~耐久：无~物品实体耐火~骑乘：保留|保护袋子及内部物品免于随袋焚毁~只能由空宠物收纳袋参与合成~可由货运拴桩代理|生物=炽足兽~物品=宠物收纳袋~系统=货运与拴桩自动化~系统=持久化与死亡掉落|PRD §10.2~RECIPES §5.5~货运与耐火已实现；非空配方拒绝待完成
铁冲角|bonded_companions:iron_ram_headpiece|registered / goat ram mechanics p0-pending|山羊铁级冲撞装备。|耐久：250~冲撞伤害加值：+1~战斗碰撞丢角概率降低：25%~修理：铁锭|完成一次冲撞命中损失耐久~承载破阵、回势与震荡|生物=山羊~附魔=破阵~附魔=回势~附魔=震荡~系统=装备与附魔生命周期|PRD §12.2~RECIPES §6.1~物品已注册；冲撞能力待实现
钻石冲角|bonded_companions:diamond_ram_headpiece|registered / goat ram mechanics p0-pending|山羊钻石级冲撞装备。|耐久：750~冲撞伤害加值：+2~战斗碰撞丢角概率降低：50%~修理：钻石|由铁冲角保留组件升级~完成一次冲撞命中损失耐久|生物=山羊~附魔=破阵~附魔=回势~附魔=震荡~系统=装备与附魔生命周期|PRD §12.2~RECIPES §6.2~物品已注册；冲撞能力待实现
下界合金冲角|bonded_companions:netherite_ram_headpiece|registered / goat ram mechanics p0-pending|山羊下界合金级冲撞装备。|耐久：1000~冲撞伤害加值：+3~战斗碰撞丢角概率降低：75%~修理：下界合金锭~物品耐火|由钻石冲角锻造升级并保留组件~完成一次冲撞命中损失耐久|生物=山羊~附魔=破阵~附魔=回势~附魔=震荡~系统=装备与附魔生命周期|PRD §12.2~RECIPES §6.3~物品已注册；冲撞能力待实现
缓冲背带|bonded_companions:impact_harness|registered / goat ram mechanics p0-pending|山羊冲撞防护背带。|护甲：+2~耐久：256~冲撞后硬直缩短：15%~修理：皮革~兼容：保护、弹射物保护、耐久、经验修补、消失诅咒|在山羊实际受到正伤害时损失 1 耐久~降低冲撞反作用阶段的硬直|生物=山羊~系统=装备与附魔生命周期|PRD §12.2、§16~RECIPES §6.4~物品已注册；冲撞能力待实现
回声背带|bonded_companions:echo_harness|registered / dolphin mechanics p0-pending|海豚专用追踪、协猎与救援背带。|护甲：+2~耐久：256~修理：海晶碎片~兼容：保护、弹射物保护、耐久、经验修补、消失诅咒|承载水中速度、目标锁定、协猎与救援附魔~实际受到正伤害时损失 1 耐久|生物=海豚~附魔=破浪~附魔=回声锁定~附魔=协猎~附魔=救援本能~系统=装备与附魔生命周期|PRD §13~RECIPES §7.1~物品已注册；完整效果待实现
热力皮夹|bonded_companions:thermal_jacket|registered / jacket gameplay p0-pending|炽足兽专用陆地适应装备。|护甲：+3~耐久：384~修理：岩浆膏~兼容：耐久、经验修补、消失诅咒及两种专属附魔|取消干燥陆地的发冷颤抖和减速~不提供雨、水或浸水免疫~实际受到正伤害时损失 1 耐久|生物=炽足兽~附魔=避湿~附魔=热行~系统=装备与附魔生命周期|PRD §14~RECIPES §7.2~物品已注册；基础皮夹效果待接入
远行背带|bonded_companions:expedition_harness|registered / sniffer mechanics p0-pending|嗅探兽探索防护装备。|护甲：+2~耐久：256~修理：皮革~兼容：保护、耐久、经验修补、消失诅咒~专属附魔：无|提供基础探索防护~不增加自动破坏方块能力|生物=嗅探兽~系统=装备与附魔生命周期|PRD §15~RECIPES §7.3~物品已注册；完整嗅探兽机制待实现
种子袋|bonded_companions:seed_pouch|registered / seed routing p0-pending|嗅探兽用植物材料容器。|容量：9 格~耐久：无~允许：种子、荚果及数据标签许可的繁殖材料~嵌套货运容器：禁止|嗅探兽挖掘所得优先进入袋中~袋满后物品掉落到世界|生物=嗅探兽~系统=持久化与死亡掉落~系统=装备与附魔生命周期|PRD §15~RECIPES §7.4~容器已注册；挖掘路由待实现
货运拴桩|bonded_companions:cargo_hitching_post|prototype automation boundary implemented / stable identity p0-pending|货运动物与自动化系统之间的唯一交换方块。|连接距离：不超过 2.5 格~单次连接：1 只合格动物~红石：有信号时锁定输入输出~比较器：输出货仓装满比例|把连接动物的货仓代理为方块物品接口~允许漏斗、Create 漏斗、溜槽、机械臂与打包物流访问~拒绝访问生物装备位|生物=马~生物=驴~生物=骡~生物=骆驼~生物=炽足兽~物品=马用驮箱~物品=驴用驮架~物品=骡用分拣驮袋~物品=骆驼商旅架~物品=耐热驮袋~系统=货运与拴桩自动化|PRD §10.3~RECIPES §5.6~基础方块物品接口已实现；稳定占用身份待完成
原版狼铠|minecraft:wolf_armor|vanilla integration / custom enchantment effects p0-pending|狼的真实原版 BODY 防具栏装备。|耐久、修复与破损：沿用原版~允许：保护、火焰保护、爆炸保护、弹射物保护、耐久、经验修补、绑定诅咒、消失诅咒~禁止：荆棘|承载忠卫、追猎和不屈~不复制第二个狼铠栏位~反伤职责只属于带刺项圈|生物=狼~物品=带刺项圈~附魔=忠卫~附魔=追猎~附魔=不屈~系统=装备与附魔生命周期|PRD §6.1、§6.3、§6.4~原版物品；本模组扩展兼容性
原版马铠|minecraft:*_horse_armor|vanilla integration / custom enchantment effects p0-pending|原版马匹防具家族。|耐久：无~允许：保护、火焰保护、爆炸保护、弹射物保护、荆棘、消失诅咒~禁止：耐久、经验修补、绑定诅咒|承载稳蹄、骑手之盾和生命甲片~只用于马，不给驴、骡或骆驼增加马铠位|生物=马~附魔=稳蹄~附魔=骑手之盾~附魔=生命甲片~系统=装备与附魔生命周期|PRD §11~原版物品家族；本模组扩展可附魔性
原版鞍|minecraft:saddle|vanilla integration|原版骑乘装备。|适用：马、驴、骡、骆驼、炽足兽~来源：原版或整合包规则|马用驮箱与马鞍互斥并占用同一存储边界~炽足兽的鞍与热力皮夹、耐热驮袋互不占位|生物=马~生物=驴~生物=骡~生物=骆驼~生物=炽足兽~物品=马用驮箱~系统=装备与附魔生命周期|PRD §10、§14~原版装备关系
原版重锤|minecraft:mace|vanilla integration / fox damage category implemented|狐狸可叼取的特殊原版武器。|狐狸攻击伤害：完整正常伤害 D×0.7~狐狸最终移动速度：×0.7~禁用：重锤坠击、摔落增伤、密度、破甲、风爆|保留普通近战命中~直接伤害类附魔在狐衔中不生效|生物=狐狸~物品=普通狐衔武器~系统=装备与附魔生命周期|PRD §8.3、§8.4~狐狸重锤伤害类别已实现
普通狐衔武器|-|vanilla integration / fox damage category implemented|狐狸真实主手允许的非专属武器与工具集合。|允许：近战武器、斧、镐、锹、锄、剪刀~禁止：弓、弩、三叉戟、盾、钓鱼竿、装液体容器~普通武器伤害：D×0.5|斧可用于普通近战~其他工具仅叼取、渲染和运输，不自动使用或破坏方块~直接增伤类附魔禁用，非直接增伤效果可工作|生物=狐狸~物品=原版重锤~物品=铁制衔月刃~物品=金制衔月刃~物品=钻石衔月刃~物品=下界合金衔月刃~系统=装备与附魔生命周期|PRD §8.3、§8.4~普通武器、重锤与衔月刃伤害类别已实现
'@

$enchantmentRows = @'
忠卫|bonded_companions:loyal_guard|data-registered / complete effect p0-pending|狼在主人附近时降低最终剩余伤害。|等级：I–III~减伤：10%/20%/30%~触发距离：主人 12 格内~自定义额外减伤总上限：80%|持续检查与主人距离并作用于最终剩余伤害~与不屈互斥|生物=狼~物品=原版狼铠~附魔=不屈~系统=装备与附魔生命周期|PRD §6.4~附魔数据存在；完整效果待实现
追猎|bonded_companions:pursuit|data-registered / complete effect p0-pending|狼追逐合法黑名单目标时强化移动与攻击。|等级：I–II~移动速度：+10%/+20%~攻击伤害：+10%/+20%~攻速：不增加|只对当前合法名单目标生效~目标失效或变为白名单时立即结束|生物=狼~物品=原版狼铠~系统=目标名单系统~系统=装备与附魔生命周期|PRD §6.4~附魔数据存在；完整效果待实现
不屈|bonded_companions:last_stand|data-registered treasure / complete effect p0-pending|把狼的一次致命伤转为短时绝境保护。|等级：I~致命伤后生命：1~保护：10 秒~恢复：生命恢复 II 10 秒~冷却：5 分钟~触发耐久消耗：狼铠 32|保护期间普通伤害无效，但虚空和管理员伤害有效~期间仍可攻击，最终伤害 -50%、最终移速 -20%~与忠卫互斥；非法共存时不屈优先|生物=狼~物品=原版狼铠~附魔=忠卫~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §6.4、§16.2~宝藏来源：古城、林地府邸、不祥试炼宝库
润腮|bonded_companions:moist_gills|data-registered / complete effect p0-pending|降低美西螈离水时的缺水消耗。|等级：I–III~缺水消耗降低：25%/50%/75%|延长离水耐受~不提供永久陆生能力|生物=美西螈~物品=美西螈背带~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §7.3~附魔数据存在；完整效果待实现
逐流|bonded_companions:currentbound|data-registered / complete effect p0-pending|提高美西螈及附近主人的水下移动。|等级：I–III~美西螈水中速度：+10%/+20%/+30%~II/III 主人水下速度：+10%/+20%~主人作用距离：16 格|只在水中生效~多个美西螈效果不叠加，只取最高等级|生物=美西螈~物品=美西螈背带~系统=装备与附魔生命周期|PRD §7.3~附魔数据存在；完整效果待实现
共生回响|bonded_companions:symbiotic_echo|data-registered treasure / complete effect p0-pending|主人或美西螈击败近期合法敌人后提供双向恢复。|等级：I–II~美西螈恢复：2/4 生命~主人：生命恢复 I 2/4 秒~冷却：10 秒~主人触发距离：16 格|只响应近期战斗记录中的合法黑名单目标~环境死亡、远程刷怪塔归属与白名单对象不触发|生物=美西螈~物品=美西螈背带~系统=目标名单系统~系统=装备与附魔生命周期|PRD §7.3、§16.2~宝藏来源：钓鱼、海底废墟、大师级渔夫交易
伏袭|bonded_companions:ambush|data-registered / complete effect p0-pending|强化狐狸扑击或脱战后的首次命中。|等级：I–III~伤害提高：25%/50%/75%~脱战判定：4 秒~冷却：5 秒|扑击命中或脱战后第一次命中触发|生物=狐狸~物品=铁制衔月刃~物品=金制衔月刃~物品=钻石衔月刃~物品=下界合金衔月刃~系统=装备与附魔生命周期|PRD §8.5~附魔数据存在；完整效果待实现
追香|bonded_companions:scent_pursuit|data-registered / complete effect p0-pending|让狐狸持续追击同一目标时逐步增伤并获得追赶速度。|等级：I–II~每次命中增伤：2%~累计上限：10%/20%~目标超过 6 格时移速：+10%/+20%|5 秒未命中、换目标、目标死亡、目标变白或狐狸等待时清零|生物=狐狸~物品=铁制衔月刃~物品=金制衔月刃~物品=钻石衔月刃~物品=下界合金衔月刃~系统=目标名单系统~系统=装备与附魔生命周期|PRD §8.5~附魔数据存在；完整效果待实现
噬生|bonded_companions:lifebite|data-registered / complete effect p0-pending|狐狸击败合法黑名单目标后恢复生命。|等级：I–II~恢复：2/4 生命~冷却：5 秒|只有合法黑名单击杀触发|生物=狐狸~物品=铁制衔月刃~物品=金制衔月刃~物品=钻石衔月刃~物品=下界合金衔月刃~系统=目标名单系统~系统=装备与附魔生命周期|PRD §8.5~附魔数据存在；完整效果待实现
轻足|bonded_companions:lightfoot|data-registered / complete effect p0-pending|降低狐狸摔落伤害。|等级：I–III~摔落伤害降低：25%/50%/75%|通过青金护符生效|生物=狐狸~物品=青金护符~系统=装备与附魔生命周期|PRD §8.6~普通专属附魔；完整效果待实现
避祸|bonded_companions:calamity_ward|data-registered / complete effect p0-pending|降低狐狸受到的爆炸伤害。|等级：I–II~爆炸伤害降低：25%/50%|通过青金护符生效|生物=狐狸~物品=青金护符~系统=装备与附魔生命周期|PRD §8.6~普通专属附魔；完整效果待实现
灵息|bonded_companions:spirit_breath|data-registered / complete effect p0-pending|狐狸脱战后持续缓慢恢复生命。|等级：I–III~启动条件：连续 8 秒未受伤~恢复频率：每 6/4/3 秒恢复 1 生命|受伤会重新开始脱战计时|生物=狐狸~物品=青金护符~系统=装备与附魔生命周期|PRD §8.6~普通专属附魔；完整效果待实现
归魂|bonded_companions:soul_recall|data-registered treasure / complete effect p0-pending|狐狸受到致命伤时保命并尝试回到主人附近。|等级：I~致命伤后生命：1~伤害保护：3 秒~冷却：10 分钟~护符耐久消耗：64|主人同维度且存在安全点时传送~找不到安全点时仍免除致命伤但留在原地~虚空和管理员伤害不触发|生物=狐狸~物品=青金护符~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §8.6、§16.2~宝藏来源：林地府邸、古城、要塞图书馆、大师级牧师交易
堡垒|bonded_companions:fortress|data-registered / complete effect p0-pending|强化守卫模式活动区内的铁傀儡减伤。|等级：I–III~剩余伤害再降低：5%/10%/15%~条件：守卫模式且位于活动区内|与应激甲片互斥~受铁傀儡额外减伤总上限约束|生物=铁傀儡~物品=铁傀儡皮革缓冲层~物品=铁傀儡铁质补强板~物品=铁傀儡钻石强化板~物品=铁傀儡下界合金强化板~附魔=应激甲片~系统=傀儡活动区与控制核心|PRD §9.4~附魔数据存在；完整效果待实现
蓄势重击|bonded_companions:charged_blow|data-registered / complete effect p0-pending|铁傀儡一段时间未攻击后的下一击增伤。|等级：I–II~蓄势时间：4 秒~下一次攻击伤害：+25%/+50%|命中后重新计时|生物=铁傀儡~物品=铁傀儡皮革缓冲层~物品=铁傀儡铁质补强板~物品=铁傀儡钻石强化板~物品=铁傀儡下界合金强化板~系统=装备与附魔生命周期|PRD §9.4~附魔数据存在；完整效果待实现
应激甲片|bonded_companions:reactive_plating|data-registered / complete effect p0-pending|铁傀儡承受重击后获得短时额外减伤。|等级：I–II~触发原始伤害：不低于 8~额外减伤：10%/20%~持续：5 秒~冷却：15 秒|与堡垒互斥~受铁傀儡额外减伤总上限约束|生物=铁傀儡~物品=铁傀儡皮革缓冲层~物品=铁傀儡铁质补强板~物品=铁傀儡钻石强化板~物品=铁傀儡下界合金强化板~附魔=堡垒~系统=装备与附魔生命周期|PRD §9.4~附魔数据存在；完整效果待实现
烬雪|bonded_companions:ember_snow|data-registered / complete effect p0-pending|让雪傀儡雪球造成额外火焰伤害与燃烧。|等级：I–III~额外火焰伤害：1/2/3~燃烧：2/4/6 秒|与深寒互斥~不爆炸、不点燃方块、不传播火焰、不伤害白名单|生物=雪傀儡~物品=雪傀儡保温皮套~物品=雪傀儡铁制护架~物品=雪傀儡钻石凝霜甲片~物品=雪傀儡下界合金熔芯甲片~附魔=深寒~系统=目标名单系统|PRD §9.5~附魔数据存在；完整效果待实现
深寒|bonded_companions:deep_freeze|data-registered / complete effect p0-pending|让雪傀儡雪球积累冰冻并施加缓慢。|等级：I–III~冰冻：30/60/90 tick~缓慢 I：2/3/4 秒|与烬雪互斥|生物=雪傀儡~物品=雪傀儡保温皮套~物品=雪傀儡铁制护架~物品=雪傀儡钻石凝霜甲片~物品=雪傀儡下界合金熔芯甲片~附魔=烬雪~系统=装备与附魔生命周期|PRD §9.5~附魔数据存在；完整效果待实现
连射|bonded_companions:rapid_volley|data-registered / complete effect p0-pending|缩短雪傀儡发射雪球的冷却。|等级：I–II~发射冷却降低：15%/30%~射程：不变|只改变发射节奏，不改变射程|生物=雪傀儡~物品=雪傀儡保温皮套~物品=雪傀儡铁制护架~物品=雪傀儡钻石凝霜甲片~物品=雪傀儡下界合金熔芯甲片~系统=装备与附魔生命周期|PRD §9.5~附魔数据存在；完整效果待实现
稳蹄|bonded_companions:surefooted|data-registered / complete effect p0-pending|降低马受到的摔落伤害。|等级：I–III~摔落伤害降低：20%/40%/60%|通过原版马铠生效|生物=马~物品=原版马铠~系统=装备与附魔生命周期|PRD §11.2~附魔数据存在；完整效果待实现
骑手之盾|bonded_companions:rider_shield|data-registered / complete effect p0-pending|骑乘时同时降低马和骑手受到的弹射物伤害。|等级：I–II~弹射物伤害降低：10%/20%~条件：正在骑乘|与原版弹射物保护互斥|生物=马~物品=原版马铠~系统=装备与附魔生命周期|PRD §11.2~附魔数据存在；完整效果待实现
生命甲片|bonded_companions:vital_plating|data-registered / complete effect p0-pending|穿戴马铠期间提高马的最大生命。|等级：I–III~最大生命：+2/+4/+6|卸下时当前生命钳制到新的最大值|生物=马~物品=原版马铠~系统=装备与附魔生命周期|PRD §11.2~附魔数据存在；完整效果待实现
破阵|bonded_companions:break_formation|data-registered / complete effect p0-pending|提高山羊冲撞伤害。|等级：I–III~冲撞伤害：+15%/+30%/+45%|只作用于冲撞，不改普通近战|生物=山羊~物品=铁冲角~物品=钻石冲角~物品=下界合金冲角~系统=装备与附魔生命周期|PRD §12.2~附魔数据存在；完整效果待实现
回势|bonded_companions:regain_momentum|data-registered / complete effect p0-pending|缩短山羊冲撞冷却。|等级：I–II~冲撞冷却降低：15%/30%|不改变冲撞安全检查|生物=山羊~物品=铁冲角~物品=钻石冲角~物品=下界合金冲角~系统=装备与附魔生命周期|PRD §12.2~附魔数据存在；完整效果待实现
震荡|bonded_companions:concussion|data-registered / complete effect p0-pending|山羊冲撞命中后施加虚弱。|等级：I–II~效果：虚弱 I~持续：2/4 秒|只在冲撞命中时触发|生物=山羊~物品=铁冲角~物品=钻石冲角~物品=下界合金冲角~系统=装备与附魔生命周期|PRD §12.2~附魔数据存在；完整效果待实现
破浪|bonded_companions:breakwater|data-registered / complete effect p0-pending|提高海豚水中移动速度。|等级：I–III~水中移动速度：+10%/+20%/+30%|仅水中生效|生物=海豚~物品=回声背带~系统=装备与附魔生命周期|PRD §13.2~附魔数据存在；完整效果待实现
回声锁定|bonded_companions:echo_lock|data-registered / complete effect p0-pending|扩大海豚主动索敌并延长失去视线后的目标保留。|等级：I–II~主动索敌半径：16/24 格~失去视线后保留：5/10 秒|仍受水中可达和名单合法性限制|生物=海豚~物品=回声背带~系统=目标名单系统~系统=伙伴模式与安全优先级|PRD §13.2~附魔数据存在；完整效果待实现
协猎|bonded_companions:cooperative_hunt|data-registered / complete effect p0-pending|主人击中水中目标后强化海豚对该目标的伤害。|等级：I–II~海豚伤害：+15%/+30%~持续：8 秒|只对主人击中的水中目标生效|生物=海豚~物品=回声背带~系统=目标名单系统~系统=装备与附魔生命周期|PRD §13.2~附魔数据存在；完整效果待实现
救援本能|bonded_companions:rescue_instinct|data-registered / complete effect p0-pending|主人水下缺氧时由附近海豚提供水下呼吸。|等级：I~触发距离：16 格~空气阈值：低于 20%~水下呼吸：8 秒~冷却：60 秒|不强制拖动玩家，避免与游泳、船和移动模组冲突|生物=海豚~物品=回声背带~系统=伙伴模式与安全优先级~系统=装备与附魔生命周期|PRD §13.2~附魔数据存在；完整效果待实现
避湿|bonded_companions:moisture_guard|data-registered / complete effect p0-pending|降低炽足兽因雨水和接触水受到的伤害。|等级：I–II~水相关伤害降低：25%/50%|不等于完全水免疫|生物=炽足兽~物品=热力皮夹~系统=装备与附魔生命周期|PRD §14.2~附魔数据存在；完整效果待实现
热行|bonded_companions:heatstride|formula unit-tested / gameplay connection p0-pending|提高炽足兽在干燥陆地和岩浆环境中的移动速度。|等级：I–II~干燥陆地：+5%/+10%~岩浆上或岩浆中：+10%/+20%|岩浆只翻倍附魔加值，不翻倍基础速度~雨水或水中不提供速度加成|生物=炽足兽~物品=热力皮夹~系统=装备与附魔生命周期|PRD §14.2~公式单元测试通过；尚未接入完整玩法
'@

$systemRows = @'
目标名单系统|-|prototype core implemented / complete species integration p0-pending|统一决定伙伴可以攻击、必须保护或回退原版行为的规则系统。|优先级：明确白名单→主人及友方→个体黑名单→种类黑名单→默认黑名单→原版行为~扫描：默认每 10 tick 错开评估~默认包含：敌对生物、苦力怕、普通蜘蛛、洞穴蜘蛛~默认排除：中立生物、监守者、凋灵、末影龙|白名单对选敌、复仇、范围伤害、反伤和附魔效果绝对生效~目标死亡、变白、跨维度、不可达或超范围时清除~水生伙伴只选水中可达目标|物品=目标名单册~生物=狼~生物=美西螈~生物=狐狸~生物=雪傀儡~生物=铁傀儡~生物=山羊~生物=海豚~系统=伙伴模式与安全优先级|PRD §5~Tech-Spec §5~核心优先级与默认标签已实现
伙伴模式与安全优先级|-|prototype / species behaviors p0-pending|控制跟随、等待、守卫、待命、搜寻以及生存动作对战斗命令的优先级。|最高优先行为：坐下、等待、召回、空气安全、缺水安全、返回活动区~跨维度：默认不追踪或传送找目标|生存与归位优先于攻击~模式变化由服务端验证和保存~不同物种只暴露其真实支持的模式|系统=目标名单系统~系统=缔结与管理~系统=傀儡活动区与控制核心~生物=狼~生物=美西螈~生物=狐狸~生物=雪傀儡~生物=铁傀儡~生物=山羊~生物=海豚~生物=嗅探兽|PRD §4、§5.5、各物种章节~可观察物种行为仍是 P0
缔结与管理|-|prototype / complete species screen p0-pending|处理伙伴身份获得、所有权验证与 Alt 管理入口。|管理输入：左 Alt + 右击~Carry On 保留：Shift + 右击~新增缔结：普通右击指定食物~服务端验证：所有权、距离、视线、生命状态、Shift 与速率|成功缔结记录主人 UUID、回满生命并持久化~只有主人可打开管理~页面应显示物种、栏位、已缔结、主人和模式|生物=狼~生物=美西螈~生物=狐狸~生物=雪傀儡~生物=铁傀儡~生物=山羊~生物=海豚~生物=马~生物=驴~生物=骡~生物=骆驼~生物=炽足兽~生物=嗅探兽~系统=伙伴模式与安全优先级|PRD §4~Tech-Spec §6、§7~网络验证已实现；完整物种管理页待完成
货运与拴桩自动化|-|prototype core implemented / stable identity and hit regions p0-pending|把动物货仓与手动交互、漏斗和 Create 物流连接，同时隔离装备栏。|支持货运动物：马、驴、骡、骆驼、炽足兽~自动化入口：仅货运拴桩~生物被骑乘时禁止开仓和自动交换~所有货运容器禁止嵌套|容器内容保存在物品本身~货运拴桩只代理货仓，不暴露名单、武器、护符、鞍、马铠、核心或补强|物品=货运拴桩~物品=马用驮箱~物品=驴用驮架~物品=骡用分拣驮袋~物品=骆驼商旅架~物品=耐热驮袋~生物=马~生物=驴~生物=骡~生物=骆驼~生物=炽足兽~系统=持久化与死亡掉落|PRD §10~Tech-Spec §10~基础 capability 边界、过滤与红石锁已实现
傀儡活动区与控制核心|-|prototype binding implemented / area behavior p0-pending|通过物品数据控制傀儡的主人、中心、范围和工作模式。|半径选项：8/16/24/32/48，默认 16~区域：水平圆柱，垂直容差 ±8~守卫追击余量：半径 +4~中心：傀儡当前位置或玩家当前位置|守卫在区内巡查并在越界后返回~跟随以主人当前位置为动态中心~待命不主动行动~傀儡不会因越界传送|物品=控制核心~生物=雪傀儡~生物=铁傀儡~系统=伙伴模式与安全优先级~系统=持久化与死亡掉落|PRD §9.2~Tech-Spec §4.3、§8~核心数据组件和绑定已实现；活动区 AI 待完成
持久化与死亡掉落|-|prototype codecs and basic drops implemented / edge cases p0-pending|保证归属、装备、容器内容和冷却在拆装、死亡、卸载与跨维度过程中不复制或丢失。|物品数据：名单、货运内容、控制核心~实体数据：归属、模式、冷却与引用~容器死亡：连同内容作为单件物品掉落|便携内容跟随物品~装桶美西螈必须往返保存全部状态~损坏或旧版数据应安全降级而非崩溃|物品=目标名单册~物品=宠物收纳袋~物品=控制核心~物品=马用驮箱~物品=驴用驮架~物品=骡用分拣驮袋~物品=骆驼商旅架~物品=耐热驮袋~物品=种子袋~系统=货运与拴桩自动化~系统=装备与附魔生命周期|PRD §4.3、§7.1、§10.1、§16~Tech-Spec §4、§14~版本化 codec 与基础死亡掉落已实现；装桶、跨维度和旧数据待验证
装备与附魔生命周期|-|data registered / complete effects and compatibility p0-pending|统一描述装备栏合法性、耐久、修理、附魔兼容、互斥与旧数据迁移。|装备位由物种与物品标签限制~正伤害才消耗穿戴装备 1 耐久~每个修理材料默认恢复最大耐久 25%~宝藏附魔不从附魔台直接获得|附魔台、铁砧、掉落、交易与指令外数据应遵守同一互斥规则~非法旧数据按确定性优先级处理~4 个旧共用补强注册项只用于迁移，不进入创造栏|系统=持久化与死亡掉落~物品=原版狼铠~物品=原版马铠~物品=普通狐衔武器~生物=狼~生物=狐狸~生物=雪傀儡~生物=铁傀儡~生物=山羊~生物=海豚~生物=炽足兽|PRD §16~Tech-Spec §7、§9、§14~31 个附魔数据已存在；完整效果、互斥、战利品和交易仍是 P0
'@

$entitiesByCategory = [ordered]@{
    '生物' = @(Parse-EntityRows -Category '生物' -Rows $creatureRows)
    '物品' = @(Parse-EntityRows -Category '物品' -Rows $itemRows)
    '附魔' = @(Parse-EntityRows -Category '附魔' -Rows $enchantmentRows)
    '系统' = @(Parse-EntityRows -Category '系统' -Rows $systemRows)
}

foreach ($entity in $entitiesByCategory['生物']) {
    $entity.Status = 'implemented / GameTest and manual gameplay acceptance pending'
}
foreach ($entity in $entitiesByCategory['物品']) {
    if ($entity.RegistryId -like 'bonded_companions:*') {
        $entity.Status = 'registered mechanics / runtime and final visual acceptance pending'
    } else {
        $entity.Status = 'vanilla integration / manual gameplay acceptance pending'
    }
}
foreach ($entity in $entitiesByCategory['附魔']) {
    $entity.Status = 'runtime implemented / manual gameplay acceptance pending'
}
$systemStatus = @{
    '目标名单系统' = 'implemented / target and whitelist GameTests pending'
    '伙伴模式与安全优先级' = 'implemented / manual species-behavior acceptance pending'
    '缔结与管理' = 'implemented / manual screen and interaction acceptance pending'
    '货运与拴桩自动化' = 'implemented / lifecycle and integration acceptance pending'
    '傀儡活动区与控制核心' = 'implemented / boundary-return GameTest pending'
    '持久化与死亡掉落' = 'implemented / lifecycle and malformed-data GameTests pending'
    '装备与附魔生命周期' = 'implemented / manual enchantment and recipe acceptance pending'
}
foreach ($entity in $entitiesByCategory['系统']) {
    $entity.Status = $systemStatus[$entity.Name]
}

New-Item -ItemType Directory -Path $entityRoot -Force | Out-Null
foreach ($category in $categoryMap.Keys) {
    New-Item -ItemType Directory -Path (Join-Path $entityRoot $category) -Force | Out-Null
}

$nameSets = @{}
foreach ($category in $entitiesByCategory.Keys) {
    $nameSets[$category] = @($entitiesByCategory[$category].Name)
}

foreach ($category in $entitiesByCategory.Keys) {
    foreach ($entity in $entitiesByCategory[$category]) {
        foreach ($relation in $entity.Relations) {
            $pair = $relation.Split('=', 2)
            if ($pair.Count -ne 2) {
                throw "Invalid relation '$relation' in $($entity.Name)"
            }
            $targetCategory = $pair[0].Trim()
            $targetName = $pair[1].Trim()
            if (-not $nameSets.ContainsKey($targetCategory) -or $targetName -notin $nameSets[$targetCategory]) {
                throw "Unresolved entity relation: $($entity.Name) -> $targetCategory/$targetName"
            }
        }
        Write-EntityNote -Entity $entity
    }
}

foreach ($category in $entitiesByCategory.Keys) {
    $indexLines = [Collections.Generic.List[string]]::new()
    $indexLines.Add('---')
    $indexLines.Add('graph_role: entity-category')
    $indexLines.Add('project: bonded_companions')
    $indexLines.Add('---')
    $indexLines.Add('')
    $indexLines.Add("# $category 索引")
    $indexLines.Add('')
    $indexLines.Add('## 上级导航')
    $indexLines.Add('')
    $indexLines.Add('- 总目录：[[_graph/MC 项目总览|总目录]]')
    $indexLines.Add('- 项目：[[_graph/Bonded Companions|Bonded Companions]]')
    $indexLines.Add('- 实体索引：[[_graph/entities/Bonded Companions 实体索引|Bonded Companions 实体索引]]')
    $indexLines.Add('')
    $indexLines.Add('> [!info] 生成索引')
    $indexLines.Add('> 节点内容来自现有规格、实现状态与注册资源，不替代原始事实来源。')
    $indexLines.Add('')
    $indexLines.Add('| 节点 | Registry ID | 当前状态 |')
    $indexLines.Add('|---|---|---|')
    foreach ($entity in $entitiesByCategory[$category]) {
        $registryId = if ($entity.RegistryId -and $entity.RegistryId -ne '-') { "``$($entity.RegistryId)``" } else { '—' }
        $indexLines.Add("| [[_graph/entities/$category/$($entity.Name)|$($entity.Name)]] | $registryId | $($entity.Status) |")
    }
    $indexLines.Add('')
    $indexLines.Add('- 返回：[[_graph/entities/Bonded Companions 实体索引|Bonded Companions 实体索引]]')
    Set-Content -LiteralPath (Join-Path $entityRoot "$category`索引.md") -Value ($indexLines -join "`n") -Encoding utf8
}

$mainIndex = @"
---
graph_role: entity-atlas
project: bonded_companions
---

# Bonded Companions 实体索引

## 上级导航

- [[_graph/MC 项目总览|总目录]]
- [[_graph/Bonded Companions|Bonded Companions]]

> [!important] 阅读边界
> 本索引呈现产品关系和当前实现状态，不修改也不替代 ``PRD.md``、``Tech-Spec.md``、``RECIPES.md`` 或代码。

## 分类入口

- [[_graph/entities/生物索引|生物索引]]：$($entitiesByCategory['生物'].Count) 种受支持生物及其定位、栏位、模式和能力。
- [[_graph/entities/物品索引|物品索引]]：$($entitiesByCategory['物品'].Count) 个模组内容与关键原版集成节点。
- [[_graph/entities/附魔索引|附魔索引]]：$($entitiesByCategory['附魔'].Count) 个自定义附魔及其适用对象、等级、效果和冲突。
- [[_graph/entities/系统索引|系统索引]]：$($entitiesByCategory['系统'].Count) 个跨物种系统。
- [[_graph/Bonded Companions 实体关系图.canvas|实体关系图 Canvas]]：固定布局的入口视图。

## 推荐使用方式

1. 从生物索引进入目标生物。
2. 在生物页查看装备、附魔和系统关系。
3. 打开该页的 Obsidian 局部关系图，观察一跳或两跳邻域。
4. 根据“当前状态”区分已注册、原型实现和 P0 待完成能力。

## 状态图例

- ``prototype``：已有可运行原型，但不代表完整玩法通过验收。
- ``registered`` / ``data-registered``：物品、方块或附魔数据已经注册。
- ``p0-pending``：完整效果或关键边界仍是发布阻塞项。
- ``vanilla integration``：原版内容节点，本模组只扩展它的使用关系。

## 原始事实来源

- [[bonded_companions/PRD|PRD]]：产品与玩法。
- [[bonded_companions/Tech-Spec|Tech-Spec]]：实现与兼容边界。
- [[bonded_companions/RECIPES|RECIPES]]：配方与获取，已与傀儡双补强线同步。
- [[bonded_companions/IMPLEMENTATION-STATUS|IMPLEMENTATION-STATUS]]：完成度与发布阻塞。
- [[bonded_companions/ART-DIRECTION|ART-DIRECTION]]：视觉和资源规格。
"@
Set-Content -LiteralPath (Join-Path $entityRoot 'Bonded Companions 实体索引.md') -Value $mainIndex -Encoding utf8

$nodes = [Collections.Generic.List[object]]::new()
$edges = [Collections.Generic.List[object]]::new()

function Add-CanvasNode {
    param([string] $Id, [string] $File, [int] $X, [int] $Y, [string] $Color, [int] $Width = 240)
    $nodes.Add([ordered]@{ id = $Id; type = 'file'; file = $File; x = $X; y = $Y; width = $Width; height = 100; color = $Color })
}

function Add-CanvasEdge {
    param([string] $Id, [string] $From, [string] $To, [string] $Label)
    $edges.Add([ordered]@{ id = $Id; fromNode = $From; fromSide = 'right'; toNode = $To; toSide = 'left'; label = $Label })
}

Add-CanvasNode -Id 'vault' -File '_graph/MC 项目总览.md' -X -1400 -Y 0 -Color '1' -Width 240
Add-CanvasNode -Id 'project' -File '_graph/Bonded Companions.md' -X -1050 -Y 0 -Color '4' -Width 260
Add-CanvasNode -Id 'atlas' -File '_graph/entities/Bonded Companions 实体索引.md' -X -680 -Y 0 -Color '4' -Width 280
Add-CanvasNode -Id 'creature-index' -File '_graph/entities/生物索引.md' -X -280 -Y -480 -Color '2'
Add-CanvasNode -Id 'item-index' -File '_graph/entities/物品索引.md' -X -280 -Y -160 -Color '3'
Add-CanvasNode -Id 'enchantment-index' -File '_graph/entities/附魔索引.md' -X -280 -Y 160 -Color '5'
Add-CanvasNode -Id 'system-index' -File '_graph/entities/系统索引.md' -X -280 -Y 480 -Color '6'
Add-CanvasEdge -Id 'vault-project' -From 'vault' -To 'project' -Label '项目入口'
Add-CanvasEdge -Id 'root-atlas' -From 'project' -To 'atlas' -Label '实体关系'
Add-CanvasEdge -Id 'atlas-creatures' -From 'atlas' -To 'creature-index' -Label '13 种生物'
Add-CanvasEdge -Id 'atlas-items' -From 'atlas' -To 'item-index' -Label '物品与方块'
Add-CanvasEdge -Id 'atlas-enchantments' -From 'atlas' -To 'enchantment-index' -Label '31 个附魔'
Add-CanvasEdge -Id 'atlas-systems' -From 'atlas' -To 'system-index' -Label '跨物种系统'

$creaturePositions = @(
    @('wolf','狼',80,-760), @('axolotl','美西螈',80,-630), @('fox','狐狸',80,-500),
    @('snow-golem','雪傀儡',80,-370), @('iron-golem','铁傀儡',80,-240), @('goat','山羊',80,-110),
    @('dolphin','海豚',80,20), @('horse','马',350,-760), @('donkey','驴',350,-630),
    @('mule','骡',350,-500), @('camel','骆驼',350,-370), @('strider','炽足兽',350,-240),
    @('sniffer','嗅探兽',350,-110)
)
$edgeCounter = 1
foreach ($entry in $creaturePositions) {
    Add-CanvasNode -Id $entry[0] -File "_graph/entities/生物/$($entry[1]).md" -X $entry[2] -Y $entry[3] -Color '2' -Width 220
    Add-CanvasEdge -Id ("creature-{0:d2}" -f $edgeCounter) -From 'creature-index' -To $entry[0] -Label '支持生物'
    $edgeCounter++
}

$systemPositions = @(
    @('targeting','目标名单系统',760,80), @('modes','伙伴模式与安全优先级',760,210),
    @('bonding','缔结与管理',760,340), @('cargo','货运与拴桩自动化',760,470),
    @('golem-area','傀儡活动区与控制核心',760,600), @('persistence','持久化与死亡掉落',760,730),
    @('equipment','装备与附魔生命周期',760,860)
)
$edgeCounter = 1
foreach ($entry in $systemPositions) {
    Add-CanvasNode -Id $entry[0] -File "_graph/entities/系统/$($entry[1]).md" -X $entry[2] -Y $entry[3] -Color '6' -Width 280
    Add-CanvasEdge -Id ("system-{0:d2}" -f $edgeCounter) -From 'system-index' -To $entry[0] -Label '系统'
    $edgeCounter++
}

$canvas = [ordered]@{ nodes = $nodes; edges = $edges }
$canvas | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $graphRoot 'Bonded Companions 实体关系图.canvas') -Encoding utf8

$summary = [ordered]@{}
foreach ($category in $entitiesByCategory.Keys) {
    $summary[$category] = $entitiesByCategory[$category].Count
}
$summary | ConvertTo-Json -Compress


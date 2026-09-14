# 两套整合包 Mods 对比报告

比较对象：

- 第一套（目标）：`机械动力-冒险加强版/mods`
- 第二套（参考）：`Mechanomania-航空学/mods`

## 结论摘要

- 第一套：190 个 JAR，解析到 188 个顶层 `modId`。
- 第二套：189 个 JAR，解析到 189 个顶层 `modId`。
- 第二套有而第一套没有：30 个 `modId`，对应 28 个 JAR。
- 两套均使用 Minecraft 1.21.1 / NeoForge 21.1.228。
- 第一套的核心较新：Create Aeronautics 1.3.2、Sable 2.0.5；第二套分别是 1.2.1、1.2.2。

不能把第二套所有差异文件一次性复制到第一套。应按以下批次添加并逐批启动测试。

## 第一批：航空与载具功能候选

建议先复制以下 7 个文件：

1. `create_aeronautics_toolgun-0.1.1.jar`
2. `createpropulsion-1.1.0.jar`
3. `drivebywire-0.2.7.jar`
4. `deployer-0.1.2.jar`
5. `extra_gauges-2.1.2.jar`
6. `simulated_gauges-1.1.0.jar`
7. `tracks-neoforge-1.21.1-1.0.1.jar`

这 7 个文件并不全是航空模组：

- Toolgun：保存、读取和删除物理载具蓝图，并用磁场枪拖动实体化结构。
- Create: Propulsion Simulated：增加推进器、固体/液体燃烧器、机翼、斯特林发动机等推进系统。
- Drive By Wire：增加控制中枢、线缆和备份块，用于组织移动结构上的控制信号。
- Deployer：供其他 Create 附属调用的程序库，本身不是主要玩法模组。
- Extra Gauges：增加整数、字符串、逻辑、比较、计数等通用自动化仪表。
- Simulated Gauges：增加高度/气压、速度和姿态仪表，直接适合飞行器仪表盘。
- Create Tracks：增加可调悬挂履带与驱动轮，属于地面载具功能；只做飞机或飞艇时可以不加。

静态依赖核对结果：

- 第一套已有 Create 6.0.10、Sable 2.0.5。
- 第一套的 Aeronautics 1.3.2 内嵌 Simulated 1.3.2 与 Offroad 1.3.2。
- 第一套的 Sable 内嵌 Sable Companion 1.6.0。
- `deployer` 自带 `compat_manager`；`extra_gauges` 和 `simulated_gauges` 需要它。
- 上述版本均满足这 7 个 JAR 在元数据中声明的最低版本。

注意：这些附属来自使用 Sable 1.2.2 的参考包。虽然其依赖范围没有设置 2.x 上限，加载器会接受 Sable 2.0.5，但仍不能仅凭元数据保证运行时 API 完全兼容。因此必须分批测试，不能直接认定绝对兼容。

## 第二批：电脑控制与蓝图功能

需要相关功能时再整组加入：

1. `cc-tweaked-1.21.1-forge-1.118.0.jar`
2. `cc_sable-neoforge-1.2.3.jar`
3. `ldlib2-neoforge-1.21.1-2.2.8-all.jar`
4. `sable-schematic-api-0.2.2.jar`
5. `synaxis-1.0.4.jar`

其中 `cc_sable` 依赖 CC: Tweaked；`synaxis` 依赖 LDLib2 与 Sable Schematic API，不能只复制单个文件。

## 第三批：移动存储

可以单独加入：

- `[精妙物流] sophisticatedstorageinmotion-1.21.1-0.10.27.208.jar`

它要求 Sophisticated Storage 1.5.31 以上；第一套已有 1.5.91，静态依赖满足。

## 可选的普通内容

- `[机械动力：筛子] createsifter-1.21.1-2.2.1.jar`：第一套已有其所需的 Create 6.0.10 与 Mechanicals 1.1.0。
- `tradeworks-1.0.7.jar`：机械动力村民交易内容，自带所需的 `compat_manager`。
- `display_case-neoforge-1.21.1-1.2.jar`：展示用途。
- `[奇异饰品] artifacts-neoforge-13.2.1.jar`：额外饰品内容。

## 不建议直接加入

- `Re-Avaritia`、`avaritia_expand`、`avaritia_integration`：第一套已有 AvaritiaNeo，且两种主体都声明 `modId=avaritia`。同时放入会产生重复主体或 API 不兼容风险。
- `c6c-lite-1.0.0.0.jar`：第一套已有完整的 `c6c-1.2.4.4.jar`，二者使用同一 `modId`。
- `[信雅互联] connector-...jar`：第一套已有与第二套无前缀 Connector 完全相同的文件；有前缀版本的内嵌 Connector 内容不同，不应叠加另一个实现。
- 第二套的旧版 Aeronautics、Sable、Create Addition、Create Big Cannons 和精妙系列：第一套现有版本更新，不应倒退覆盖。
- `Tectonic + Lithostitched`、`Epic Villages`、`RoadWeaver`：会改变世界生成；只适合明确希望改变新生成区块时加入。
- `Distant Horizons`、`Continuity`、`Tweakerge + MaFgLib`：属于客户端显示或操作优化，不是航空内容；第一套还使用本地快照版 Sodium/Iris，应另行测试兼容性。
- `badpackets`：当前推荐批次没有声明必须依赖它，不需要作为“看起来像前置”而单独加入。

## 同名模组的版本差异

第一套较新的重点组件包括：Aeronautics、Sable、Create Addition、Create Big Cannons、Sophisticated Core/Storage/Backpacks、L2Library、NetMusic。

第二套较新的普通组件包括：Alloy Smelter、AttributeFix、KubeJSTweaks、Trading Floor、Xaero Minimap/World Map。它们属于“升级候选”，不是缺失模组；若要更新，应逐个核对更新日志，不能直接覆盖。

第一套的 Sodium/Iris 是配套的本地快照版本，不应只替换其中一个。

## 后续验证建议

每批添加后进行一次启动，并检查 `logs/latest.log` 中的：

- `Missing or unsupported mandatory dependencies`
- `NoSuchMethodError` / `NoClassDefFoundError`
- Mixin apply failure
- Registry duplicate 或 duplicate mod id

如果目标是完整复刻第二套玩法，仅比较 `mods` 仍然不够；还需比较两个实例的 `config`、`defaultconfigs`、`kubejs`、数据包与资源包。配方、兼容规则和禁用内容往往保存在这些目录，而不是模组 JAR 内。

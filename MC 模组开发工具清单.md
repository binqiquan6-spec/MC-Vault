# MC 模组开发工具清单（1.21.1 / NeoForge 21.1.x）

整理日期：2026-09-14
适用范围：Minecraft 1.21.1 + NeoForge 21.1.x + Java 21 项目（主要面向 `bonded_companions`／羁绊生灵，其余同版本项目可通用）
整理方式：四个并行调研子任务，经 GitHub REST / raw README / Atom feed / Modrinth API / maven.neoforged.net 目录 / 官方站点实访交叉核实；标注为"已核实"的条目经过双重来源确认。

> 本文是**工作区级的独立工具资料**，既不属于 `bonded_companions` 项目（该项目受其自身 `AGENTS.md` 与 `MEMORY.md` 约束），也不属于 `_graph` 关系图层。文中链接一律使用普通 Markdown 链接与行内代码，不使用 `[[wikilink]]`，以免被 Obsidian 关系图当作项目关系边。

> **采用说明（2026-09-14）**：本文仅是候选工具资料，不是安装清单或开发指令。`bonded_companions` 的实际工具准入、使用阶段与停止条件以项目内 `DEVELOPMENT-EXECUTION-PLAN.md` 为准。当前不安装任何新增工具；尤其不把 `modlens-mcp` 作为常驻 MCP，因为其运行依赖和每轮上下文开销与当前降低 token 消耗的目标冲突。

---

## 0. 速览：本项目最该用的内容

| 优先级 | 工具 | 解决的痛点 | 对应项目文档中的待办 |
|---|---|---|---|
| ★★★ | [ModDevGradle `gameTestServer`](https://github.com/neoforged/ModDevGradle) + NeoForge TestFramework | 把实体持久化/死亡掉落/跨维度/区块卸载写成可进 CI 的断言 | `IMPLEMENTATION-STATUS.md` P0 第 1、3 项 |
| ★★★ | [packwiz](https://github.com/packwiz/packwiz) + [PrismLauncher](https://github.com/PrismLauncher/PrismLauncher) | 可回滚、可重复的整合包克隆实例 | P0 第 5 项、验收标准第 13 条 |
| ★★★ | [spark](https://github.com/lucko/spark) + [Eclipse MAT](https://github.com/eclipse-mat/mat) | 定位上次那类 1.9 GB 堆的 OutOfMemoryError 与卡顿 | P0 第 7 项性能预算 |
| ★★☆ | [modlens-mcp](https://github.com/Mattabase/modlens-mcp) | 209 模组环境下的 mixin/AT/tag 冲突矩阵与崩溃归因 | 五个 mixin 的兼容风险 |
| ★★☆ | [Misode 附魔生成器](https://misode.github.io/enchantment/) | 31 个数据驱动附魔与互斥标签的字段骨架 | `RECIPES.md` 第 9 节、31 个附魔 JSON |
| ★★☆ | [Spyglass](https://github.com/SpyglassMC/Spyglass) | 离线校验附魔/配方/tag 的 ID 与引用拼写 | 125 个 JSON 资源的持续正确性 |
| ★☆☆ | [Blockbench](https://github.com/JannisX11/blockbench) + [Pixelorama](https://github.com/Orama-Interactive/Pixelorama) | 8 个傀儡物品模型与 28 张贴图的产出 | 视觉资产解冻后 P0 第 6 项 |
| ★☆☆ | [Crash-Assistant](https://github.com/KostromDan/Crash-Assistant) | 崩溃现场自动聚合与约 50 类已知问题检测 | 实机排查提速 |

一句话取舍：**建构复现能力（前三条）> 校验与排查（第四条）> 内容生产效率（第五、六条）> 美术产出（第七条）**。

---

## 1. 先确定版本边界（1.21.1 专属，决定哪些工具可用）

| 变更 | 起始版本 | 对 1.21.1 的意义 |
|---|---|---|
| 附魔数据驱动 `data/<ns>/enchantment/*.json` | 1.21 | ✅ 1.21.1 就是新格式：`description` / `supported_items` / `primary_items` / `exclusive_set` / `weight` / `max_level` / `min_cost` / `max_cost` / `anvil_cost` / `slots` / `effects`（效果由"附魔效果组件"构成） |
| 物品组件 data components | 1.20.5 | ✅ 合成结果写成 `{"id": ..., "count": ...}`，附魔存在 `DataComponentTypes.ENCHANTMENT` |
| 物品模型定义 `assets/<ns>/items/*.json` | **1.21.4** | ❌ **1.21.1 没有这个改动**，仍旧使用 `assets/<ns>/models/item/*.json`（`parent` + `textures` + `overrides`）加 `blockstates/*.json` |
| 贴图 PNG | 版本无关 | ✅ 任何像素工具都适用 |
| 资源包 / 数据包格式号 | 1.21–1.21.1 | 资源包 34 / 数据包 48 |

两条直接后果：

1. 用 Blockbench 时目标版本设 1.21.1，**不要导出 `items/` 定义**；否则客户端会整片紫黑缺失纹理。
2. 任何声称"生成 `items/` 定义"或自述只到 1.20.x 的数据包工具，都**不能**直接产出 1.21.1 资源（例如 `MCDatapacker` 自述仅到 1.20.4）。

参考：[NeoForge 1.21.1 附魔文档](https://docs.neoforged.net/docs/1.21.1/resources/server/enchantments/)、[NeoForge Documentation 仓库](https://github.com/neoforged/Documentation)（含 `versioned_docs/version-1.21.1`）。

---

## 2. 项目已经在用的工具链（无需重复引入）

| 项目现状 | 说明 | 结论 |
|---|---|---|
| ModDevGradle（NeoForge 官方推荐 Gradle 插件） | 负责反编译、`runClient`/`runServer`、`runData`、打包 | 保持；重点是把 `gameTestServer` 用起来 |
| Parchment `1.21.1` / `2024.11.17` | 已在 `gradle.properties` 配置，为官方映射补**参数名与 javadoc** | ✅ [ParchmentMC/Parchment](https://github.com/ParchmentMC/Parchment) 已在用，无需新增 |
| 本地产源码 | `./gradlew genSources` 一次后 IDE 内可离线全文检索原版类 | 与 `neoforge-21.1.x-sources.jar` 等价，无需额外工具 |
| Jade 软兼容 | `compileOnly` + `neoforge.mods.toml` 声明 `optional` | 既是兼容目标，也是游戏内查注册 ID 的调试工具 |
| ForgeCDN 主机改写 + `gradle/local-maven` | 解决目标网络访问不到官方 NeoForged Maven | 与国内镜像方案等价，属**本地方案**，不必替换 |
| 自写 `tools/` 脚本 | 贴图处理、附魔资源生成、批次准备 | 与"像素编辑器 + 自写换色脚本"的正确路线一致 |

NeoForge 21.1.x 仍在持续发版（采集时点最新 `21.1.250`），说明 1.21.1 是事实上的长期维护版本，工具链值得认真投入。

---

## 3. 项目脚手架与模板（结论：本项目用不上）

| 工具 | 说明 | 适配判断 |
|---|---|---|
| [neoforged/mod-generator](https://github.com/neoforged/mod-generator)（网页版 <https://neoforged.net/mod-generator/>） | NeoForge **官方**项目生成器，可直接生成 1.21.1 骨架 | ➖ 只适合开新项目；CLI 尚未正式发布，别指望进 CI |
| [MDK-1.21.1-ModDevGradle](https://github.com/NeoForgeMDKs/MDK-1.21.1-ModDevGradle) | 官方 1.21.1 模板仓库（★143，活跃） | ✅ 当"标准答案"对照 `build.gradle` 是否漂移；该仓库不受理 issue/PR |
| [neoforged/ModDevGradle](https://github.com/neoforged/ModDevGradle) | 官方推荐插件本体 | ✅ 保留并对齐版本 |
| [neoforged/NeoGradle](https://github.com/neoforged/NeoGradle) | 上一代插件 | ⚠️ 存量可用，新项目别选 |
| [MDK-1.21.1-NeoGradle](https://github.com/NeoForgeMDKs/MDK-1.21.1-NeoGradle) | 同上、旧插件版 | ⚠️ 仅对照 |
| [neoforged/NeoForge](https://github.com/neoforged/NeoForge) | 本体；查 21.1.x 补丁号与 `neoforge.mods.toml` 规范以此为准 | ✅ 权威来源 |
| [minecraft-dev/MinecraftDev](https://github.com/minecraft-dev/MinecraftDev) | IntelliJ 插件：项目向导、Mixin 支持、AT 补全、NBT 编辑器，233 万+ 下载、免费 | ✅ 清单里唯一对**已有项目**立刻有价值的 IDE 工具 |
| [Player005/multiloader-mod-template](https://github.com/Player005/multiloader-mod-template) | Fabric+NeoForge 单源码模板，默认分支恰好 1.21.1 | ⚠️ ★0、单人维护，仅供参考 |
| [architectury/architectury-loom](https://github.com/architectury/architectury-loom)、[architectury-api](https://github.com/architectury/architectury-api) | 多加载器环境插件与 API，均活跃 | ➖ 只有要做多加载器才需要 |
| [architectury/architectury-templates](https://github.com/architectury/architectury-templates) | 多加载器模板 | ❌ 2023-11 后无提交且无 1.21.1 分支，**不要照搬** |

**通用结论**："一键写 gradle 配置 / 自动生成 `neoforge.mods.toml`"这类独立工具基本不存在——能力已被 Gradle 插件本体吸收（占位符替换由 MDK 预置的 `processResources` 完成）。VSCode 方向没有活跃维护的 Java 版模组开发扩展，官方只推荐 IntelliJ IDEA 与 Eclipse。

---

## 4. 数据与资源生成（📦 产出 JSON）

| 工具 | 说明 | 联网 | 1.21.1 |
|---|---|---|---|
| [Misode 生成器](https://github.com/misode/misode.github.io)（<https://misode.github.io/>） | 配方/战利品表/标签/进度/**附魔**/`pack.mcmeta`/converter 的可视化生成（MIT，★916，活跃） | 在线，可克隆自建离线 | ✅ 覆盖 1.21.x；注意其中 `item_definition`/`block_definition` 是 1.21.4+ 语义 |
| [Misode 附魔生成器](https://misode.github.io/enchantment/) + [附魔标签生成器](https://misode.github.io/tag/enchantment/) | 31 个附魔与 `exclusive_set` 互斥集的字段骨架 | 在线 | ✅ 1.21 字段集与 1.21.1 一致 |
| 框架内建 `DatapackBuiltinEntriesProvider` + `RegistrySetBuilder` | 把附魔/配方/标签/战利品表 datagen 到 `src/generated/...`，字段随版本类型安全 | 构建期离线 | ✅ 最推荐 |
| 框架内建 `ModelProvider` / `BlockStateProvider` / `ItemModelProvider` | 批量生成物品与方块模型 JSON | 构建期离线 | ✅ [官方 1.21.1 datagen 文档](https://github.com/neoforged/Documentation/blob/main/versioned_docs/version-1.21.1/resources/client/models/datagen.md) |
| [SpyglassMC/Spyglass](https://github.com/SpyglassMC/Spyglass) | VS Code 数据包语言服务器：语法高亮、补全、ID 与引用校验、错误诊断 | 完全离线 | ✅ 建议与 Misode 形成"生成 + 校验"闭环 |
| [misode/mcmeta](https://github.com/misode/mcmeta) | 各版本原版数据与资源的版本化快照（★620，活跃） | 需联网克隆（约 6.6 GB） | ✅ 查"1.21.1 原版 JSON 到底长什么样"最快 |
| [lyingice/data_recipe_generator](https://github.com/lyingice/data_recipe_generator) | NeoForge 1.21.1 专用数据包配方生成器（MIT），游戏内生成配方 JSON | 进游戏 | ✅ 明确 1.21.1 |
| [300f20t/Recipe-Generator](https://github.com/300f20t/Recipe-Generator) | 游戏内可视化配方编辑器，31 万下载 | 进游戏 | ✅ 含 1.21.1 |
| [deveworld/cobble](https://github.com/deveworld/cobble) | 类 Python 语言编译成数据包，可脚本化批量生成 | 离线编译 | ✅ 面向 1.21+ |
| [misode/packtest](https://github.com/misode/packtest) | 用数据包作测试用例断言行为（Fabric 执行器） | 进游戏 | ➖ NeoForge 专用特性不覆盖 |
| [IoeCmcomc/MCDatapacker](https://github.com/IoeCmcomc/MCDatapacker) | 桌面离线数据包编辑器 | 完全离线 | ❌ 自述仅到 1.20.4，别用它产出 1.21.1 JSON |

> 关键限制：附魔的**效果逻辑**必须写 Java 并注册效果组件（`BuiltInRegistries.ENCHANTMENT_EFFECT_COMPONENT_TYPE`、`ConditionalEffect`、`runIterationOnItem`），纯 JSON 只能表达数据部分——本项目的做法已经是正确路线。

---

## 5. 模型、贴图与本地化（🎨 画图/建模 + 语言）

### 5.1 建模与像素画

| 工具 | 说明 | 备注 |
|---|---|---|
| [JannisX11/blockbench](https://github.com/JannisX11/blockbench) | 低模 3D 编辑 + 像素画绘制 + 导出 Java Block/Item JSON（GPL-3.0，★5900，活跃） | ✅ 桌面完全离线；1.21.1 传统模型格式正好匹配 |
| [Orama-Interactive/Pixelorama](https://github.com/Orama-Interactive/Pixelorama) | 开源像素画工具，MIT，★10.3k，活跃 | ✅ 有 GDScript 扩展 API + CLI，适合写调色板批量换色出图 |
| [LibreSprite/LibreSprite](https://github.com/LibreSprite/LibreSprite) | Aseprite 最后 GPLv2 提交的社区分支，GPL-2.0，★8.4k | ⚠️ 无脚本/批处理 API，按纯 GUI 用 |
| [aseprite/aseprite](https://github.com/aseprite/aseprite) | 商业像素画工具，有 Lua + CLI | ⚠️ **源码可见但非开源**（EULA，付费），许可不纯 |
| [ingobeans/minecraft-texture-to-model](https://github.com/ingobeans/minecraft-texture-to-model) | PNG 贴图转等价模型 JSON，用于超过 16×16 的大件物品 | 离线，传统模型格式，可用于 1.21.1 |
| [4mbl/textureminer](https://github.com/4mbl/textureminer) | 提取/缩放 MC 物品方块贴图的库 + CLI | 用于风格对齐；**勿分发 Mojang 素材** |
| [JustAlittleWolf/ConnectedTexturesGenerator](https://github.com/JustAlittleWolf/ConnectedTexturesGenerator) | 从源图批量生成 OptiFine ctm 连接纹理 | 版本无关，但只做方块 CTM |
| [lukebemishprojects/DynamicAssetGenerator](https://github.com/lukebemishprojects/DynamicAssetGenerator) | NeoForge **运行期**资源/贴图生成库（LGPL-3.0） | 仓库内有 "Bump to 1.21.1" 提交；属运行期生成，不是创作期画图 |

**重要负面结论（已核实）**：GitHub 上**没有**成熟可靠、开箱即用的"批量生成自定义物品贴图"工具。现存只有人工像素编辑器、方块 CTM 脚本、图集马赛克工具（[LoneHiggs/Minecraftify](https://github.com/LoneHiggs/Minecraftify)）、一个面向 64×64 图标的新 AI Skill（[yzxr123/blockpixel-artist](https://github.com/yzxr123/blockpixel-artist)）、以及 0★ 未验证的 `payangar-dev/texlab`。务实做法 = **一个像素编辑器 + 自写调色板换色脚本**（本项目 `tools/` 已在做）。

### 5.2 语言文件与本地化

| 工具 | 说明 | 备注 |
|---|---|---|
| [CFPAOrg/Minecraft-Mod-Language-Package](https://github.com/CFPAOrg/Minecraft-Mod-Language-Package) | 简体中文模组汉化资源包主仓库，★1194，活跃 | ✅ 术语与官方译名最权威来源；**是资源包，不能直接塞进 mod 的 lang** |
| [CFPAOrg/TransRules](https://github.com/CFPAOrg/TransRules) | CFPA 翻译规范与术语标准 | ✅ "附魔名怎么译、物品名大小写"照此执行 |
| [CFPAOrg/I18nUpdateMod3](https://github.com/CFPAOrg/I18nUpdateMod3) | 自动汉化更新 mod 源码 | 1.21.1 可用；可作为"玩家已有汉化"的兼容对象 |
| [Mai-xiyu/xtmc-minecraft-mod-translator](https://github.com/Mai-xiyu/xtmc-minecraft-mod-translator) | 语言文件/字节码翻译，多 AI 模型适配 | ⚠️ 只作初稿，必须人工校对 |
| [zVictorium/Minecraft-Mod-Translator](https://github.com/zVictorium/Minecraft-Mod-Translator) | 解包 jar → 翻译内部语言文件 → 重新打包 | 批量处理第三方 jar 时方便 |
| [Misode lang 生成器](https://misode.github.io/lang/) | 生成 `en_us.json` 骨架、核对合法语言代码 | ✅ |

建议自建校验（比找现成工具更省事）：几十行脚本比对 `en_us.json` 与 `zh_cn.json` 的 key 集合，检查缺 key、多余 key、`%s` / `%1$s` 占位符数量不一致。与项目 `AGENTS.md` 的"游戏内文本用中文、翻译键保持可本地化"一致。

---

## 6. 查阅原版代码与映射（三条合法路径）

| 工具 | 说明 | 1.21.1 |
|---|---|---|
| [neoforged/ModDevGradle](https://github.com/neoforged/ModDevGradle) | 默认走 NeoForm 管线，在**本地**产出 Minecraft 源码 jar，IDE 内全文检索；README 明确只支持 21.0.x 之后 | ✅ 本项目已用 |
| `neoforge-21.1.x-sources.jar`（[Maven 目录](https://maven.neoforged.net/releases/net/neoforged/neoforge/)） | 已发布的 1.21.1 源码 jar（含 NeoForge 补丁，官方名反编译），无需自行反编译 | ✅ 已核实目录与 `moddev-config.json` |
| [ParchmentMC/Parchment](https://github.com/ParchmentMC/Parchment) | 给官方映射补**参数名与 javadoc**（官方映射两者都没有），CC0，★335 | ✅ 本项目已在 `gradle.properties` 启用 |
| [FabricMC/mcsrc](https://github.com/FabricMC/mcsrc) → mcsrc.dev | 在线反编译源码浏览器：类/成员搜索、版本 diff，★551 | ✅ mappings.dev 官方推荐的替代品 |
| [katana-project/slicer](https://github.com/katana-project/slicer) → slicer.run | 浏览器内拖入**任意 jar**反编译，能识别 NeoForge mod，★171 | ✅ 排查第三方 jar 行为特别有用 |
| [neoforged/NeoForm](https://github.com/neoforged/NeoForm) / [NeoFormRuntime](https://github.com/neoforged/NeoFormRuntime) | 反编译管线 / 独立 CLI | ✅ 1.21.1 配置以 Maven 制品形式存在（没有名为 1.21.1 的分支） |
| [neoforged/snowblower](https://github.com/neoforged/snowblower) | NeoForge 官方产出反编译源码仓库的 CI 工具 | ➖ **不是**给模组作者交互使用的 |
| [FabricMC/yarn](https://github.com/FabricMC/yarn) | Fabric 官方映射，CC0 | ❌ 对 NeoForge **不可用**（命名空间不同），仅作阅读 Fabric 资料时的名词对照 |

命名与事实更正（避免踩坑）：

- `neoforged/neoform-runtime` = 404，正确仓库名是 CamelCase 的 [NeoFormRuntime](https://github.com/neoforged/NeoFormRuntime)。
- `Mojang/piston-meta` = 404：**官方映射没有 GitHub 镜像**，只有 `piston-meta.mojang.com` 的 `version_manifest_v2.json` → 各版本 JSON 的 `downloads.client_mappings`（ProGuard txt），且只有字段/方法名。
- `FabricMC/mappings.dev` 仓库不存在；且 **mappings.dev 已停止更新**。
- [linkie/linkie-core](https://github.com/linkie/linkie-core) 最后提交 2024-02、**从未发布任何 release**；[linkie-web](https://github.com/linkie/linkie-web) 最后一次功能性改动 2024-07。版本枚举虽为动态、1.21.x 运行时"能跑"，但**不可作为 1.21+ 的可靠依赖**；不存在官方 1.21+ 维护分支。
- 战略背景：Mojang 已宣布（2025-10-29，经 mappings.dev 站点说明确认）Java 版构建将不再混淆，yarn / mappings.dev / Linkie 系映射查询工具正在退场。**对 1.21.1 无影响**——官方映射 + Parchment 1.21.1 + NeoForm/ModDevGradle 仍是正确技术栈，只是别把 Linkie 系当长期依赖。
- 生态已转向 MCP 形态：[linkie-mcp](https://github.com/GRAINALCOHOL/linkie-mcp)、[minecraft-modding-mcp](https://github.com/adhi-jp/minecraft-modding-mcp)（把映射/反编译源码暴露给 LLM，可生成 Mixin target 与 Access Widener 行）。

---

## 7. 测试与运行时校验

| 工具 | 说明 | 适配判断 |
|---|---|---|
| NeoForge TestFramework（`@TestHolder` / `DynamicTest` / `@GameTest`） | 官方游戏内测试框架 | ✅ [TESTFRAMEWORK.md](https://github.com/neoforged/NeoForge/blob/1.21.x/docs/TESTFRAMEWORK.md)、[NEOGAMETESTS.md](https://github.com/neoforged/NeoForge/blob/1.21.x/docs/NEOGAMETESTS.md) |
| [ModDevGradle](https://github.com/neoforged/ModDevGradle) 的 `gameTestServer` + `net.neoforged:testframework` | 无客户端对 `MinecraftServer` 断言，JUnit `@ExtendWith(EphemeralTestServerProvider.class)`；CI 下自动 `disableRecompilation` | ✅ **本项目最该补的一环** |
| [gnembon/fabric-carpet](https://github.com/gnembon/fabric-carpet) + [Carpet-TIS-Addition](https://github.com/TISUnion/Carpet-TIS-Addition) | `/tick freeze`、`/tick warp`、`/player` 假人、`/log`、`/forceload` | ⚠️ 仅 Fabric 实例；手工复现"卸载瞬间掉落丢失/翻倍"最实用 |
| [MCDReforged](https://github.com/MCDReforged/MCDReforged) | Python 服务端控制框架，脚本化发指令 + 解析控制台，把跨维度/区块卸载流程变成可重复脚本 | ➖ 进阶方案 |
| [tryashtar/nbt-studio](https://github.com/tryashtar/nbt-studio)、[Amulet](https://github.com/Amulet-Team/Amulet-Map-Editor) | 直接读 `region/*.mca`、`level.dat`、`entities/` | ✅ 确认"存档里到底是不是两份实体"的终审证据 |
| [pop4959/Chunky](https://github.com/pop4959/Chunky) | 预生成区块，把区块加载/卸载变成可控实验条件 | ✅ 排除"区块未加载"造成的假阳性 |
| [Snownee/Jade](https://github.com/Snownee/Jade) | 所见即所得的注册 ID / 数据 HUD（1.21.1 + neoforge 已核实） | ✅ 既是兼容目标也是调试工具 |
| [Flemmli97/DebugUtils](https://github.com/Flemmli97/DebugUtils)、[maruohon/minihud](https://github.com/maruohon/minihud) | 命令调试与调试 HUD | ✅ 分支跟到 1.21.1 |
| NBT Viewer（<https://modrinth.com/mod/items-nbt-viewer>） | 物品/实体 NBT(SNBT) 悬浮提示，1.21.1 可用 | ⚠️ 非开源 |

**能验证"实体持久化 / 死亡掉落 / 区块卸载 / 跨维度"复制与丢失 bug 的手段排序**：

1. NeoForge TestFramework + GameTest —— 唯一能把"生成实体 → 击杀/传送 → 校验掉落 → 卸载区块 → 重载 → 校验 NBT 唯一性"写成可重复、可进 CI 断言的方式；用 `@EmptyTemplate`/`StructureTemplateBuilder` 与 `startSequence().thenIdle()`/`thenWaitUntil()` 控制时间轴。
2. `gameTestServer` + `EphemeralTestServerProvider` —— 无客户端、几分钟一轮，适合每日回归。
3. Carpet 的 `/tick freeze` + `/tick warp` + `/player` + `/log` —— tick 级手工推进复现竞态。
4. MCDReforged —— 真实服务端脚本化跑 `/execute in`、`/forceload`、`/data get entity`，前后 NBT 快照 diff。
5. NBTStudio / Amulet —— 直接看存档文件，终审证据。
6. spark `heapdump` → Eclipse MAT —— 若"复制"表现为内存增长，用 hprof dominator tree 确认存在两份实例。

不可用提醒：[maruohon/tellme](https://github.com/maruohon/tellme) 最高仅 1.20.4 且无 NeoForge → **1.21.1 不可用**；`Not-Enough-Crashes` 加载器支持未核实，**不要假定 NeoForge 可用**；`Slord6/tick-freeze` 是 Bukkit 插件，不适用于 NeoForge。

---

## 8. 整合包管理与复现

| 工具 | 说明 | 适配判断 |
|---|---|---|
| [packwiz/packwiz](https://github.com/packwiz/packwiz) | TOML 元数据、可 git 版本控制；`packwiz curseforge import` 可从现有 CurseForge 包导入；内置 HTTP server 分发 | ✅ 让"克隆实例做兼容测试"可重复 |
| [packwiz-installer-bootstrap](https://github.com/packwiz/packwiz-installer-bootstrap) | Prism/MultiMC 预启动命令，每次启动把实例同步到指定 pack 版本 | ✅ 与上一条配套 |
| [PrismLauncher/PrismLauncher](https://github.com/PrismLauncher/PrismLauncher) | 多实例隔离、组件锁版本、每实例独立 Java/内存、实例复制导出、原生支持 packwiz-installer | ✅ 上次 OOM 属内存配置问题，这里能固定基线 |
| [ATLauncher](https://github.com/ATLauncher/ATLauncher) | 一键装官方整合包到独立实例 | ✅ |
| [Griefed/ServerPackCreator](https://github.com/Griefed/ServerPackCreator) | 从整合同一键生成服务端包（含 NeoForge） | ✅ 验证"客户端包能否起服务端" |
| [justin-carver/sculkr](https://github.com/justin-carver/sculkr) | packwiz 伴侣：生成 modlist（Markdown/JSON）、diff 两版本 mod 集合 | ✅ |
| [TheBossMagnus/modpack-changelogger](https://github.com/TheBossMagnus/modpack-changelogger) | 比较两个 `.mrpack`/`.zip`，输出 mod/资源包/配置增删改清单 | ✅ |
| [ModdingX/ModListCreator](https://github.com/ModdingX/ModListCreator) | 从 `manifest.json` 生成带版本与链接的 mod 列表 | ⚠️ 2025-02 后停更，仍可用 |
| [MultiMC/Launcher](https://github.com/MultiMC/Launcher) | Prism 上游 | ⚠️ 发布停滞，建议改用 Prism |

与项目 `AGENTS.md` 的"绝不在正式存档/实例上测试、先复制实例再验证"完全吻合。

---

## 9. 兼容性排查与崩溃定位

| 工具 | 说明 | 适配判断 |
|---|---|---|
| [Mattabase/modlens-mcp](https://github.com/Mattabase/modlens-mcp) | 反编译并索引整个 `mods/` 目录，输出 **mixin 冲突矩阵、AT/AW 冲突、tag 冲突、sidedness、依赖缺失、崩溃归因**；`check_mod_compat` 可对新 jar 预检 | ✅ 明确支持 `loader=neoforge mcVersion=1.21.1`；对 5 个 mixin 很值 |
| [KostromDan/Crash-Assistant](https://github.com/KostromDan/Crash-Assistant) | 崩溃 GUI：自动聚合游戏/启动器日志、crash-report、`hs_err`，约 50 种已知问题检测（MixinApply、DuplicatedMods、OOM、UnsupportedClassVersion…）、类/包查找、jdeps 依赖分析、一键上传 | ✅ **1.21.1 + NeoForge 双重核实**（Modrinth 版本表 + 仓库 `neoforge/` 分支）；本体离线可用，许可为自定义非 OSI |
| [aternosorg/mclogs-integration](https://github.com/aternosorg/mclogs-integration) / [mclogs](https://github.com/aternosorg/mclogs) | 一键上传日志到 mclo.gs 并分析；后者是服务本体，可自建 | ✅ 1.21.1 + neoforge；上传必须联网 |
| [SpongePowered/Mixin](https://github.com/SpongePowered/Mixin) | 冲突排查用 `-Dmixin.debug.verbose=true` / `-Dmixin.debug.export=true` | ✅ 官方手段 |
| [LlamaLad7/MixinExtras](https://github.com/LlamaLad7/MixinExtras) | `@WrapOperation` 等注入器，显著降低注入点冲突面 | ✅ 对本项目 5 个 mixin 有边际收益 |
| 原生机制（优于第三方数据库） | `neoforge.mods.toml` 的 `[[dependencies.<modid>]] type="incompatible"/"discouraged"`（可写 reason），以及 `[[mixins]] requiredMods=[...]` 让 mixin 仅在目标模组存在时应用 | ✅ [官方 modfiles 文档](https://docs.neoforged.net/docs/1.21.1/gettingstarted/modfiles/) |
| [mosemister/MixinDetector](https://github.com/mosemister/MixinDetector) | 扫描 `mods/` 列出哪些 jar 含 mixin | ⚠️ 面向 1.16–1.19 时代 |
| [Sinytra/Connector](https://github.com/Sinytra/Connector) | Fabric→NeoForge 兼容层，其 issue 区即事实上的跨加载器兼容数据库 | ➖ 参考 |

---

## 10. 性能与内存（含 OOM 定位）

| 工具 | 说明 | 适配判断 |
|---|---|---|
| [lucko/spark](https://github.com/lucko/spark) + [spark-viewer](https://github.com/lucko/spark-viewer) | `/spark profiler`、`heapsummary`、`heapdump`、tps/msp | ✅ 1.21.1 NeoForge 有正式构建 |
| [Eclipse MAT](https://github.com/eclipse-mat/mat) | 分析 spark heapdump 的 hprof：dominator tree、重复对象、泄漏引用链 | ✅ OOM 定位主力 |
| [async-profiler](https://github.com/async-profiler/async-profiler) | CPU/分配采样火焰图，JProfiler 的开源替代，`alloc` 模式定位分配热点 | ✅ |
| [tasgon/observable](https://github.com/tasgon/observable) | 可视化卡顿来源（方块实体/实体/区块耗时） | ✅ 1.21.1 分支，可验证"100 只伙伴不形成 10 tick 尖峰" |
| [Oracle VisualVM](https://github.com/oracle/visualvm) | 图形化 JVM 监控 | ✅ |
| [malte0811/FerriteCore](https://github.com/malte0811/FerriteCore)、[embeddedt/ModernFix](https://github.com/embeddedt/ModernFix) | 降低区块/模型内存占用；启动与内存/兼容性修复 | ✅ 1.21.1 有版本；属整合包侧缓解手段 |
| [FxMorin/MemoryLeakFix](https://github.com/FxMorin/MemoryLeakFix) | 修多个泄漏 | ⚠️ 主要 Fabric 1.20 时代，1.21 支持有限，未逐版本核实 |

---

## 11. 构建辅助与网络加速

- 插件：[ModDevGradle](https://github.com/neoforged/ModDevGradle)（`jarJar` 版本区间、`neoFormRuntime.enableCache`、`validateAccessTransformers`）、[GradleUp/shadow](https://github.com/GradleUp/shadow)（已从 `johnrengelman/shadow` 迁移）、[neoforged/JarJar](https://github.com/neoforged/JarJar)、[ben-manes/gradle-versions-plugin](https://github.com/ben-manes/gradle-versions-plugin)（`dependencyUpdates` 检查依赖漂移）、[modrinth/minotaur](https://github.com/modrinth/minotaur)（发布到 Modrinth）。`SpongePowered/MixinGradle` 已被 MDG/NeoGradle 内建，一般无需单独引入。
- 中国网络：[bangbang93/openbmclapi](https://github.com/bangbang93/openbmclapi)（Minecraft 资源镜像分发网络，加速 NeoForge/Forge 安装器与依赖库）；Maven 侧在 `settings.gradle` 的 `pluginManagement` / `dependencyResolutionManagement` 注入阿里云 `https://maven.aliyun.com/repository/public` 与 `.../gradle-plugin`（插件门户镜像最关键）、腾讯云 `https://mirrors.cloud.tencent.com/nexus/repository/maven-public/`、华为云 `https://repo.huaweicloud.com/repository/maven/`；`gradle-wrapper.properties` 的 `distributionUrl` 可指向镜像。
- 本项目已有等价方案（ForgeCDN 主机改写 + `gradle/local-maven` 坐标元数据），**无需替换**；若要进一步提速，加镜像源即可。

---

## 12. 明确不要用的（已停更、已归档或版本不符）

| 项目 | 状态 | 原因 |
|---|---|---|
| [architectury/architectury-templates](https://github.com/architectury/architectury-templates) | 实质停更（2023-11 后无提交） | 无 1.21.1 分支 |
| [minecraft-addon-tools/generator-minecraft-addon](https://github.com/minecraft-addon-tools/generator-minecraft-addon) | 已归档 | Yeoman 生成器，且面向**基岩版 Addon** |
| [moiCR/Vscraft](https://github.com/moiCR/Vscraft) | 已归档 | VSCode 项目生成器，作者已归档 |
| [Straywave/ModTemplate](https://github.com/Straywave/ModTemplate)、[Ayydxn/Multi-ModLoaderTemplate](https://github.com/Ayydxn/Multi-ModLoaderTemplate) | 停更（2024） | — |
| Fabric 侧多个同名 "Mod-Template-Generator" | ★0–1 个人实验 | 不可依赖 |
| [IoeCmcomc/MCDatapacker](https://github.com/IoeCmcomc/MCDatapacker) | 版本不符 | 自述仅到 1.20.4 |
| [maruohon/tellme](https://github.com/maruohon/tellme) | 版本不符 | 最高 1.20.4 且无 NeoForge |
| [unascribed/BlockRenderer](https://github.com/unascribed/BlockRenderer) 等 | 版本不符 | 仅到 1.16 |
| [linkie/linkie-core](https://github.com/linkie/linkie-core) / linkie-web | 维护滞后、无 release | 不可作为 1.21+ 的映射依赖 |
| `mappings.dev` / `FabricMC/mappings.dev` | 站点停更、仓库不存在 | 已被 mcsrc.dev / slicer.run 取代 |
| [architectury/architectury-api](https://github.com/architectury/architectury-api)、[architectury-loom](https://github.com/architectury/architectury-loom) | 活跃但**不需要** | 单加载器项目引入纯属增加复杂度 |
| [FabricMC/fabric-loom](https://github.com/FabricMC/fabric-loom)、[fabric-example-mod](https://github.com/FabricMC/fabric-example-mod)、[yarn](https://github.com/FabricMC/yarn) | 活跃但**不适用** | 命名空间与加载器均不同 |
| [MinecraftForge/MinecraftForge](https://github.com/MinecraftForge/MinecraftForge) | 活跃但**不适用** | 对 1.21.1 NeoForge 无价值 |

---

## 13. 落地清单（建议执行顺序）

1. **把 GameTest 变成 CI 能力**：在既有 `gametest` 包基础上接入 `gameTestServer` + `testframework`，优先覆盖 `IMPLEMENTATION-STATUS.md` P0 第 1、3 项（实体存档、死亡掉落、跨维度、区块卸载的复制/丢失）。
2. **建立可复现实例**：用 PrismLauncher 复制实例 + packwiz 快照目标整合包，得到"能一键回到出问题版本组合"的兼容矩阵环境。
3. **补齐观测手段**：实例内放 spark（+ 需要时 heapdump → MAT）与 Crash-Assistant；开发期用 Jade 查注册 ID。
4. **数据层闭环**：31 附魔与互斥标签用 Misode 生成器核对字段 → 交给框架 datagen 或现有 JSON → 用 Spyglass 做 ID/引用校验，形成"生成 → 校验 → `runData`"三步。
5. **兼容预检**：每个新 jar 用 modlens-mcp 做一次 mixin/AT/tag 冲突预检，再进 209 模组克隆实例。
6. **美术解冻后**：Blockbench（目标版本 1.21.1，勿导出 `items/` 定义）+ Pixelorama/自写换色脚本产出 8 个傀儡物品模型与贴图，遵守 `ART-DIRECTION.md` 的 64×64 硬边像素与 8–16 色规范。
7. **本地化**：以 CFPA 语言包 + TransRules 为译名基准，自写脚本比对 `en_us.json`/`zh_cn.json` 的 key 与占位符一致性。

---

## 14. 附：调研口径与不确定项

- 维护状态（★ 数、最后提交日期、`archived` 标记）取自 GitHub REST/搜索 API、raw README、Atom feed，采集时点 2026-09；部分仓库在 API 匿名额度耗尽后改用页面与搜索交叉验证。
- 版本适配（1.21.1 / NeoForge）在关键条目上做了双重核实：Crash-Assistant、Jade、packwiz、Prism、spark、ModDevGradle、Parchment、Blockbench、Misode 附魔字段、`neoforge-21.1.x-sources.jar`。
- 以下判断基于最后提交时间、**未逐版本核对 1.21.1 兼容矩阵**，落地前请在 Prism 实例实测：`MemoryLeakFix`、`tellme`、`carpet-extra`、`ModListCreator`、`JarJar`、`MixinGradle`、`BlockRenderer`。
- 仅搜索未核实、不应直接采纳：`ratph6/mc-mod-mcp`、Mojang/Fabric "取消混淆"公告原文、"Cobblemon Linkie"、Not-Enough-Crashes 的加载器支持。
- 本文只做工具索引，不改变任何项目结论：`bonded_companions` 的 `PRD.md`、`Tech-Spec.md`、`RECIPES.md`、`ART-DIRECTION.md`、`DEVELOPMENT-RULES.md`、`IMPLEMENTATION-STATUS.md`、`MEMORY.md` 仍是各自领域的唯一事实来源。

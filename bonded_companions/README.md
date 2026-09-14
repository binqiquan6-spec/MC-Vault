# Bonded Companions

中文暂定名：羁绊生灵  
状态：`0.1.0` 技术原型，可构建、可由 NeoForge 加载，但尚未达到完整 v1 发布门槛

## 项目目标

为 Minecraft 1.21.1 NeoForge 整合包增加可靠的伙伴名单、物种专属装备与驮运物流：

- 白名单绝对保护，黑名单驱动伙伴主动攻击。
- 狼、美西螈、狐狸、傀儡、山羊和海豚具有不同的合理战斗机制。
- 马、驴、骡、骆驼与炽足兽承担差异化运输。
- 货运拴桩是漏斗与机械动力交换物品的唯一入口。
- 嗅探兽作为非战斗探索伙伴。

## 已实现的基础

- 13 种目标生物的识别、归属数据与物种栏位规则。
- 白名单优先、主人保护、黑名单与默认敌对目标的中央判定策略。
- 左 Alt + 右击的服务端校验管理入口；Shift + 右击不被拦截。
- 专用管理页面、名单记录、驯服/绑定行为、装备、便携货仓与货运拴桩能力。
- 狐狸普通武器、重锤和衔月刃的核心伤害倍率。
- 31 种专属附魔、两套互不通用的四级傀儡装备线，以及保留组件的装备升级配方。
- 全部基础物品、合成表、双语文本和数据标签；新美术在用户提供模板前保持冻结。
- 自动化单元测试、9 项 NeoForge 运行时 GameTest、干净构建与数据运行加载检查。

`IMPLEMENTATION-STATUS.md` 记录逐项完成情况和发布阻塞项。当前 JAR 只适合开发实例，不应放入正式存档。

## 文档导航

- PRD.md：完整玩法、栏位、数值、附魔、AI、货运与 v1 验收标准。
- RECIPES.md：全部新增物品的 3×3 合成表、升级和附魔获取。
- Tech-Spec.md：数据模型、按键与网络、伤害结算、物流能力和第三方兼容。
- DEVELOPMENT-RULES.md：从规格到验证的开发规则、里程碑和发布门禁。
- DEVELOPMENT-EXECUTION-PLAN.md：当前阶段、逐任务顺序、工具分工与 AI 探索边界。
- IMPLEMENTATION-STATUS.md：当前代码覆盖、已验证内容和剩余工作。
- MEMORY.md：长期决定、用户修正、兼容调查与风险。
- AGENTS.md：本项目内工作的约束和文档契约。

## 目标环境

- Minecraft 1.21.1
- NeoForge 21.1.x / Java 21
- 当前指定兼容：Create、Carry On、Horseman、Modular Golems、Create: Meowchanics、Jade
- 其他模组暂不制作专用适配；只在整合包复制实例中发现真实冲突后再评估。

只在本目录开发。目标整合包与正式存档不会被直接修改；以后生成的 JAR 先进入复制实例验证。

## 构建

```powershell
.\gradlew.bat test build --no-daemon
.\gradlew.bat runGameTestServer --no-daemon
```

开发 JAR 输出到 `build/libs/bonded_companions-0.1.0.jar`。

## 下一开发阶段

先完成 `IMPLEMENTATION-STATUS.md` 中剩余的 P0 阻塞项，再验证当前六个指定软兼容边界；未点名模组的专用兼容不进入当前制作范围。

---
graph_role: vault-hub
scope: minecraft-workspace
aliases: [总目录, 总索引, MOC, Home, 首页]
---

# MC 工作区总目录

> [!important] AI / 新会话从这里开始
> 这是整个 Vault 的唯一入口。先读本页的「AI 阅读协议」和「任务路由表」，再跳到目标任务文件；不要通读全库。

## 0. AI 阅读协议

1. 任何任务的第一步：打开本页，读第 0、1 节。
2. 在「任务路由表」找到匹配的任务类型；没有匹配时，先补充路由表再执行。
3. 按「第 1 站」进入入口页，再按「直达」进入目标文件的对应章节。
4. 只读目标章节；不要通读整个文件，更不要逐文件扫描全库。
5. 找不到目标时才搜索，并限制范围：`rg "关键词" <目标目录> --glob "*.md"`。
6. **排除区**：`useful_recipes_1.21.1_neoforge/` 不读取、不搜索、不修改、不索引。
7. 新增或删除 md 后，必须运行 `_graph/tools/update-vault-index.ps1` 更新本页附录。
8. 遵守根 `AGENTS.md` 的「AI Navigation Contract」；项目内部仍以各项目 `AGENTS.md` 和原始规格为准。

## 1. 任务路由表

| 我要做什么 | 第 1 站 | 直达 | 禁止先读 |
|---|---|---|---|
| 改玩法/数值/验收 | [[_graph/产品与玩法\|产品与玩法]] | [[bonded_companions/PRD#6. 狼\|PRD §6 狼]] / [[bonded_companions/PRD#7. 美西螈\|PRD §7 美西螈]] / [[bonded_companions/PRD#8. 狐狸\|PRD §8 狐狸]] / [[bonded_companions/PRD#9. 傀儡\|PRD §9 傀儡]] / [[bonded_companions/PRD#10. 坐骑、货运与物流\|PRD §10 货运]] | Tech-Spec 全文 |
| 改实现/网络/兼容 | [[_graph/技术架构\|技术架构]] | [[bonded_companions/Tech-Spec#5. 名单规则引擎\|Tech-Spec §5]] / [[bonded_companions/Tech-Spec#11. 第三方兼容边界\|Tech-Spec §11]] / [[bonded_companions/IMPLEMENTATION-STATUS#Current P0 Release Blockers\|STATUS P0]] | PRD 全文 |
| 做美术/贴图/模型 | [[_graph/美术与内容\|美术与内容]] | [[bonded_companions/ART-DIRECTION#6. 31 件非方块物品的 64×64 图案构图\|ART §6]] / [[bonded_companions/ART-DIRECTION#8. 模型几何与绑定\|ART §8]] | Tech-Spec 全文 |
| 领当前代码任务 | [[_graph/开发与交付\|开发与交付]] | [[bonded_companions/DEVELOPMENT-EXECUTION-PLAN#7. 第一张允许执行的代码任务卡\|执行计划 §7 任务卡]] | 其他所有文档 |
| 查完成度/阻塞 | [[bonded_companions/IMPLEMENTATION-STATUS\|IMPLEMENTATION-STATUS]] | [[bonded_companions/IMPLEMENTATION-STATUS#Current P0 Release Blockers\|P0 阻塞项]] | PRD 全文 |
| 查配方/获取 | [[_graph/entities/Bonded Companions 实体索引\|实体索引]] → [[_graph/entities/物品索引\|物品索引]] | 对应物品页的「属性」和「依据」 | Tech-Spec 全文 |
| 查某生物配置 | [[_graph/entities/生物索引\|生物索引]] | 生物页的「属性 / 关系 / 依据」 | PRD 全文 |
| 查附魔等级/冲突 | [[_graph/entities/附魔索引\|附魔索引]] | 附魔页的「属性 / 关系 / 依据」 | 其他附魔页 |
| 查跨系统规则 | [[_graph/entities/系统索引\|系统索引]] | 系统页的「属性 / 关系 / 依据」 | PRD 全文 |
| 查开发规则/门禁 | [[_graph/开发与交付\|开发与交付]] | [[bonded_companions/DEVELOPMENT-RULES#9. 验证规则\|DEVELOPMENT-RULES §9]] | 其他文档 |
| 查工具选型 | [[MC 模组开发工具清单\|工具清单]] | [[MC 模组开发工具清单#0. 速览：本项目最该用的内容\|§0 速览]] + 对应章节 | 32KB 全文 |
| 查整合包差异 | [[_graph/周边项目与补丁\|周边项目与补丁]] | [[mod_comparison_mechanomania/REPORT\|REPORT]] 对应批次 | 全部项目文档 |
| 查周边补丁 | [[_graph/周边项目与补丁\|周边项目与补丁]] | 对应项目的包装页 | 全部项目文档 |

## 2. 项目区

### 2.1 Bonded Companions（主项目）

- 项目导航：[[_graph/Bonded Companions|Bonded Companions]]
- 项目入口：[[bonded_companions/README|README]]
- 产品：[[bonded_companions/PRD|PRD]]、[[bonded_companions/RECIPES|RECIPES]]
- 技术：[[bonded_companions/Tech-Spec|Tech-Spec]]、[[bonded_companions/IMPLEMENTATION-STATUS|IMPLEMENTATION-STATUS]]、[[bonded_companions/MEMORY|MEMORY]]
- 美术：[[bonded_companions/ART-DIRECTION|ART-DIRECTION]]
- 交付：[[bonded_companions/AGENTS|AGENTS]]、[[bonded_companions/DEVELOPMENT-RULES|DEVELOPMENT-RULES]]、[[bonded_companions/DEVELOPMENT-EXECUTION-PLAN|DEVELOPMENT-EXECUTION-PLAN]]
- 实体：[[_graph/entities/Bonded Companions 实体索引|实体索引]]

### 2.2 周边项目与补丁

- 统一入口：[[_graph/周边项目与补丁|周边项目与补丁]]
- 有文档项目：[[curios_headwear_slot/README|Curios 头饰栏]]、[[mod_comparison_mechanomania/REPORT|Mechanomania 模组对比]]
- 无文档项目：[[_graph/周边项目与补丁/EpicTerrain 1.21.1 补丁|EpicTerrain]]、[[_graph/周边项目与补丁/Aeronautics Sodium 0.6.13 兼容版|Aeronautics Sodium]]、[[_graph/周边项目与补丁/Immersive Portals × Sable 兼容|Immersive Portals × Sable]]

### 2.3 排除区

- ❌ `useful_recipes_1.21.1_neoforge/`：按用户要求不索引、不处理、不读取、不搜索。

## 3. 工作区规则与资料

- [[AGENTS|Vault Instructions]]：Vault 级工作规则和导航契约。
- [[MEMORY|Workspace Memory]]：工作区长期决策。
- [[MC 模组开发工具清单|MC 模组开发工具清单]]：候选工具调研，不是安装清单。

## 4. 可视化入口

- [[_graph/MC 项目关系图.canvas|MC 项目关系图]]
- [[_graph/Bonded Companions 实体关系图.canvas|Bonded Companions 实体关系图]]
- [[_graph/entities/Bonded Companions 实体索引|Bonded Companions 实体索引]]

## 5. 维护与校验

- 关系规范：[[_graph/GRAPH-SPEC|GRAPH-SPEC]]
- 实体图谱生成：[[_graph/tools/build-entity-graph.ps1|build-entity-graph.ps1]]
- 总目录索引生成：[[_graph/tools/update-vault-index.ps1|update-vault-index.ps1]]
- 全库导航校验：[[_graph/tools/validate-vault-navigation.ps1|validate-vault-navigation.ps1]]
- 实体图谱校验：[[_graph/tools/validate-entity-graph.ps1|validate-entity-graph.ps1]]
- 受保护文档哈希：[[_graph/PROTECTED-FILES.sha256|PROTECTED-FILES.sha256]]

## 6. 动态索引（Folder Overview）

> 以下代码块由 Folder Overview 插件渲染。插件未启用时显示为代码块，不影响下方静态附录。
> 动态范围限定在 `_graph` 和 `bonded_companions`，不会列出排除目录。

### 关系层导航

```folder-overview
title: 关系层导航
folderPath: _graph
depth: 1
showTitle: true
includeTypes:
  - markdown
```

### Bonded Companions 文档

```folder-overview
title: Bonded Companions 文档
folderPath: bonded_companions
depth: 1
showTitle: true
includeTypes:
  - markdown
```

## 附录：全量文档索引（自动生成，勿手改）

<!-- BEGIN AUTO-INDEX -->
> [!example]- 全量文档索引（自动生成，勿手改）
> 运行 `_graph/tools/update-vault-index.ps1` 重新生成；自动排除 `useful_recipes_1.21.1_neoforge/`、`.nav-backup/`、`build/`、`.gradle/`。
>
> **(根目录)（3）**
> - [[AGENTS.md|Vault Instructions]]
> - [[MC 模组开发工具清单.md|MC 模组开发工具清单（1.21.1 / NeoForge 21.1.x）]]
> - [[MEMORY.md|Workspace Memory]]
>
> **bonded_companions（10）**
> - [[bonded_companions/AGENTS.md|Project Instructions]]
> - [[bonded_companions/ART-DIRECTION.md|羁绊生灵美术方向与资产规格]]
> - [[bonded_companions/DEVELOPMENT-EXECUTION-PLAN.md|Bonded Companions 开发执行计划]]
> - [[bonded_companions/DEVELOPMENT-RULES.md|模组制定规则与开发流程]]
> - [[bonded_companions/IMPLEMENTATION-STATUS.md|Implementation Status]]
> - [[bonded_companions/MEMORY.md|Project Memory]]
> - [[bonded_companions/PRD.md|羁绊生灵（Bonded Companions）产品规格]]
> - [[bonded_companions/README.md|Bonded Companions]]
> - [[bonded_companions/RECIPES.md|物品合成与获取表]]
> - [[bonded_companions/Tech-Spec.md|Bonded Companions 技术规格]]
>
> **_graph（11）**
> - [[_graph/Bonded Companions.md|Bonded Companions]]
> - [[_graph/GRAPH-SPEC.md|Bonded Companions Entity Graph Specification]]
> - [[_graph/NAVIGATION-REPORT.md|导航体系建设报告（2026-09-14）]]
> - [[_graph/产品与玩法.md|产品与玩法]]
> - [[_graph/技术架构.md|技术架构]]
> - [[_graph/开发与交付.md|开发与交付]]
> - [[_graph/美术与内容.md|美术与内容]]
> - [[_graph/周边项目与补丁.md|周边项目与补丁]]
> - [[_graph/周边项目与补丁/Aeronautics Sodium 0.6.13 兼容版.md|Aeronautics Sodium 0.6.13 兼容版]]
> - [[_graph/周边项目与补丁/EpicTerrain 1.21.1 补丁.md|EpicTerrain 1.21.1 补丁]]
> - [[_graph/周边项目与补丁/Immersive Portals × Sable 兼容.md|Immersive Portals × Sable 兼容]]
>
> **_graph/entities（5）**
> - [[_graph/entities/Bonded Companions 实体索引.md|Bonded Companions 实体索引]]
> - [[_graph/entities/附魔索引.md|附魔 索引]]
> - [[_graph/entities/生物索引.md|生物 索引]]
> - [[_graph/entities/物品索引.md|物品 索引]]
> - [[_graph/entities/系统索引.md|系统 索引]]
>
> **_graph/entities/生物（13）**
> - [[_graph/entities/生物/炽足兽.md|炽足兽]]
> - [[_graph/entities/生物/海豚.md|海豚]]
> - [[_graph/entities/生物/狐狸.md|狐狸]]
> - [[_graph/entities/生物/狼.md|狼]]
> - [[_graph/entities/生物/骡.md|骡]]
> - [[_graph/entities/生物/骆驼.md|骆驼]]
> - [[_graph/entities/生物/驴.md|驴]]
> - [[_graph/entities/生物/马.md|马]]
> - [[_graph/entities/生物/美西螈.md|美西螈]]
> - [[_graph/entities/生物/山羊.md|山羊]]
> - [[_graph/entities/生物/铁傀儡.md|铁傀儡]]
> - [[_graph/entities/生物/嗅探兽.md|嗅探兽]]
> - [[_graph/entities/生物/雪傀儡.md|雪傀儡]]
>
> **_graph/entities/物品（37）**
> - [[_graph/entities/物品/宠物收纳袋.md|宠物收纳袋]]
> - [[_graph/entities/物品/带刺项圈.md|带刺项圈]]
> - [[_graph/entities/物品/缓冲背带.md|缓冲背带]]
> - [[_graph/entities/物品/回声背带.md|回声背带]]
> - [[_graph/entities/物品/货运拴桩.md|货运拴桩]]
> - [[_graph/entities/物品/金制衔月刃.md|金制衔月刃]]
> - [[_graph/entities/物品/控制核心.md|控制核心]]
> - [[_graph/entities/物品/骡用分拣驮袋.md|骡用分拣驮袋]]
> - [[_graph/entities/物品/骆驼商旅架.md|骆驼商旅架]]
> - [[_graph/entities/物品/驴用驮架.md|驴用驮架]]
> - [[_graph/entities/物品/马用驮箱.md|马用驮箱]]
> - [[_graph/entities/物品/美西螈背带.md|美西螈背带]]
> - [[_graph/entities/物品/目标名单册.md|目标名单册]]
> - [[_graph/entities/物品/耐热驮袋.md|耐热驮袋]]
> - [[_graph/entities/物品/普通狐衔武器.md|普通狐衔武器]]
> - [[_graph/entities/物品/青金护符.md|青金护符]]
> - [[_graph/entities/物品/热力皮夹.md|热力皮夹]]
> - [[_graph/entities/物品/铁冲角.md|铁冲角]]
> - [[_graph/entities/物品/铁傀儡皮革缓冲层.md|铁傀儡皮革缓冲层]]
> - [[_graph/entities/物品/铁傀儡铁质补强板.md|铁傀儡铁质补强板]]
> - [[_graph/entities/物品/铁傀儡下界合金强化板.md|铁傀儡下界合金强化板]]
> - [[_graph/entities/物品/铁傀儡钻石强化板.md|铁傀儡钻石强化板]]
> - [[_graph/entities/物品/铁制衔月刃.md|铁制衔月刃]]
> - [[_graph/entities/物品/下界合金冲角.md|下界合金冲角]]
> - [[_graph/entities/物品/下界合金衔月刃.md|下界合金衔月刃]]
> - [[_graph/entities/物品/雪傀儡保温皮套.md|雪傀儡保温皮套]]
> - [[_graph/entities/物品/雪傀儡铁制护架.md|雪傀儡铁制护架]]
> - [[_graph/entities/物品/雪傀儡下界合金熔芯甲片.md|雪傀儡下界合金熔芯甲片]]
> - [[_graph/entities/物品/雪傀儡钻石凝霜甲片.md|雪傀儡钻石凝霜甲片]]
> - [[_graph/entities/物品/原版鞍.md|原版鞍]]
> - [[_graph/entities/物品/原版狼铠.md|原版狼铠]]
> - [[_graph/entities/物品/原版马铠.md|原版马铠]]
> - [[_graph/entities/物品/原版重锤.md|原版重锤]]
> - [[_graph/entities/物品/远行背带.md|远行背带]]
> - [[_graph/entities/物品/种子袋.md|种子袋]]
> - [[_graph/entities/物品/钻石冲角.md|钻石冲角]]
> - [[_graph/entities/物品/钻石衔月刃.md|钻石衔月刃]]
>
> **_graph/entities/附魔（31）**
> - [[_graph/entities/附魔/堡垒.md|堡垒]]
> - [[_graph/entities/附魔/避祸.md|避祸]]
> - [[_graph/entities/附魔/避湿.md|避湿]]
> - [[_graph/entities/附魔/不屈.md|不屈]]
> - [[_graph/entities/附魔/伏袭.md|伏袭]]
> - [[_graph/entities/附魔/共生回响.md|共生回响]]
> - [[_graph/entities/附魔/归魂.md|归魂]]
> - [[_graph/entities/附魔/回声锁定.md|回声锁定]]
> - [[_graph/entities/附魔/回势.md|回势]]
> - [[_graph/entities/附魔/烬雪.md|烬雪]]
> - [[_graph/entities/附魔/救援本能.md|救援本能]]
> - [[_graph/entities/附魔/连射.md|连射]]
> - [[_graph/entities/附魔/灵息.md|灵息]]
> - [[_graph/entities/附魔/破浪.md|破浪]]
> - [[_graph/entities/附魔/破阵.md|破阵]]
> - [[_graph/entities/附魔/骑手之盾.md|骑手之盾]]
> - [[_graph/entities/附魔/轻足.md|轻足]]
> - [[_graph/entities/附魔/热行.md|热行]]
> - [[_graph/entities/附魔/润腮.md|润腮]]
> - [[_graph/entities/附魔/深寒.md|深寒]]
> - [[_graph/entities/附魔/生命甲片.md|生命甲片]]
> - [[_graph/entities/附魔/噬生.md|噬生]]
> - [[_graph/entities/附魔/稳蹄.md|稳蹄]]
> - [[_graph/entities/附魔/协猎.md|协猎]]
> - [[_graph/entities/附魔/蓄势重击.md|蓄势重击]]
> - [[_graph/entities/附魔/应激甲片.md|应激甲片]]
> - [[_graph/entities/附魔/震荡.md|震荡]]
> - [[_graph/entities/附魔/忠卫.md|忠卫]]
> - [[_graph/entities/附魔/逐流.md|逐流]]
> - [[_graph/entities/附魔/追猎.md|追猎]]
> - [[_graph/entities/附魔/追香.md|追香]]
>
> **_graph/entities/系统（7）**
> - [[_graph/entities/系统/持久化与死亡掉落.md|持久化与死亡掉落]]
> - [[_graph/entities/系统/缔结与管理.md|缔结与管理]]
> - [[_graph/entities/系统/伙伴模式与安全优先级.md|伙伴模式与安全优先级]]
> - [[_graph/entities/系统/货运与拴桩自动化.md|货运与拴桩自动化]]
> - [[_graph/entities/系统/傀儡活动区与控制核心.md|傀儡活动区与控制核心]]
> - [[_graph/entities/系统/目标名单系统.md|目标名单系统]]
> - [[_graph/entities/系统/装备与附魔生命周期.md|装备与附魔生命周期]]
>
> **curios_headwear_slot（1）**
> - [[curios_headwear_slot/README.md|Curios 头饰栏]]
>
> **mod_comparison_mechanomania（1）**
> - [[mod_comparison_mechanomania/REPORT.md|两套整合包 Mods 对比报告]]
>
<!-- END AUTO-INDEX -->

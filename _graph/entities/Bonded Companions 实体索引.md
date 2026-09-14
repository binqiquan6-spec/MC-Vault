---
graph_role: entity-atlas
project: bonded_companions
---

# Bonded Companions 实体索引

## 上级导航

- [[_graph/MC 项目总览|总目录]]
- [[_graph/Bonded Companions|Bonded Companions]]

> [!important] 阅读边界
> 本索引呈现产品关系和当前实现状态，不修改也不替代 `PRD.md`、`Tech-Spec.md`、`RECIPES.md` 或代码。

## 分类入口

- [[_graph/entities/生物索引|生物索引]]：13 种受支持生物及其定位、栏位、模式和能力。
- [[_graph/entities/物品索引|物品索引]]：37 个模组内容与关键原版集成节点。
- [[_graph/entities/附魔索引|附魔索引]]：31 个自定义附魔及其适用对象、等级、效果和冲突。
- [[_graph/entities/系统索引|系统索引]]：7 个跨物种系统。
- [[_graph/Bonded Companions 实体关系图.canvas|实体关系图 Canvas]]：固定布局的入口视图。

## 推荐使用方式

1. 从生物索引进入目标生物。
2. 在生物页查看装备、附魔和系统关系。
3. 打开该页的 Obsidian 局部关系图，观察一跳或两跳邻域。
4. 根据“当前状态”区分已注册、原型实现和 P0 待完成能力。

## 状态图例

- `prototype`：已有可运行原型，但不代表完整玩法通过验收。
- `registered` / `data-registered`：物品、方块或附魔数据已经注册。
- `p0-pending`：完整效果或关键边界仍是发布阻塞项。
- `vanilla integration`：原版内容节点，本模组只扩展它的使用关系。

## 原始事实来源

- [[bonded_companions/PRD|PRD]]：产品与玩法。
- [[bonded_companions/Tech-Spec|Tech-Spec]]：实现与兼容边界。
- [[bonded_companions/RECIPES|RECIPES]]：配方与获取，已与傀儡双补强线同步。
- [[bonded_companions/IMPLEMENTATION-STATUS|IMPLEMENTATION-STATUS]]：完成度与发布阻塞。
- [[bonded_companions/ART-DIRECTION|ART-DIRECTION]]：视觉和资源规格。

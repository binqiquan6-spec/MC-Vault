# Bonded Companions Entity Graph Specification

## Goal

Extend the document-level Obsidian graph into a product-domain graph without modifying files under `bonded_companions`.

The graph must answer:

- Which creatures are supported and what roles, modes, abilities, and safety rules they have.
- Which items can be equipped by which creatures.
- What attributes, durability, capacity, repair material, and special behavior each item has.
- Which custom enchantments apply to each item and creature, including levels, effects, and conflicts.
- Which shared systems connect combat, management, persistence, cargo, automation, and golem areas.
- Which relationships are specified versus only partially implemented.

## Scope

- 13 supported creature nodes.
- 32 public mod content nodes: 31 registered items and the Cargo Hitching Post block.
- Required vanilla integration nodes for Wolf Armor, Horse Armor, Saddle, Mace, and ordinary fox-held weapons.
- 31 custom enchantment nodes.
- 7 shared system nodes.
- Category indexes and one fixed-layout entity overview Canvas.

Hidden prototype-era reinforcement registry entries are documented in the migration system note, not presented as usable equipment.

## Source Priority

1. `bonded_companions/PRD.md` for product behavior.
2. `bonded_companions/Tech-Spec.md` for implementation boundaries.
3. Current registries, recipe resources, and translations for actual IDs and registered content.
4. `bonded_companions/IMPLEMENTATION-STATUS.md` for completeness claims.
5. `bonded_companions/RECIPES.md` for acquisition, except where current recipe resources reflect the newer species-specific reinforcement split.

## Generated Layout

```text
_graph/entities/
├─ 生物/
├─ 物品/
├─ 附魔/
├─ 系统/
├─ 生物索引.md
├─ 物品索引.md
├─ 附魔索引.md
├─ 系统索引.md
└─ Bonded Companions 实体索引.md
```

Every entity note contains typed relationships. Native Obsidian graph edges remain visually unlabeled, so the relationship type is written beside each wikilink. The Canvas uses labeled edges for the stable overview.

## Status Language

- `specified`: authoritative behavior exists in the product specification.
- `registered`: registry/data resource exists.
- `prototype`: a basic implementation exists, but the complete v1 behavior is not verified.
- `p0-pending`: complete effect or release behavior remains a P0 blocker.
- `vanilla-integration`: the node is not a mod-owned item but participates in mod behavior.

## Acceptance Criteria

- Existing protected documents retain their recorded SHA-256 hashes.
- Every generated wikilink resolves to an existing note or project document.
- Every Canvas file node resolves and every edge references existing node IDs.
- Each creature links to its equipment, enchantments, and shared systems.
- Each item states its important attributes and links back to applicable creatures and enchantments.
- Each custom enchantment states max level, effect, applicability, conflict, and implementation status.
- Global graph colors distinguish creatures, items, enchantments, systems, relationship hubs, and source documents.
- No community plugin is required.

## Current Source Alignment

- `PRD.md`, `RECIPES.md`, registry resources, and implementation status now use separate four-level reinforcement lines for Snow Golems and Iron Golems.
- Four prototype-era shared reinforcement IDs remain hidden migration inputs and are represented under the equipment lifecycle system rather than as player-facing item nodes.


## Vault Navigation Extension

> 上级：[[_graph/MC 项目总览|总目录]] · [[_graph/Bonded Companions|Bonded Companions]]

- 唯一入口：`_graph/MC 项目总览.md`（别名：总目录 / 总索引 / MOC / Home）。
- AI 阅读协议：先读总目录第 0、1 节，再按任务路由表跳到目标章节；禁止全库通读。
- 全量索引：由 `_graph/tools/update-vault-index.ps1` 生成总目录附录。
- 排除区：`useful_recipes_1.21.1_neoforge/` 不索引、不处理。
- 校验器：`_graph/tools/validate-vault-navigation.ps1` 检查入链、可达性、断链、Canvas、颜色组与保护哈希。
- 导航变更保持在 `_graph` 层；13 个项目文档正文按方案 A 保持不改。

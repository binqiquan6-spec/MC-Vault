# Vault Instructions

## Scope

- This folder is an Obsidian vault and a workspace for multiple Minecraft projects.
- `bonded_companions` is the primary NeoForge 1.21.1 project and uses Gradle.
- Other top-level folders are independent utilities, compatibility patches, reports, or data packs.

## Safety and Structure

- Do not move, rename, or rewrite existing project files solely to improve Obsidian navigation.
- Keep Obsidian-only relationship notes inside `_graph`.
- Treat links from `_graph` as navigation metadata, not as product or implementation authority.
- Read a project's own `AGENTS.md` and `MEMORY.md` before changing anything inside that project.
- Preserve unrelated user changes and generated assets.

## Obsidian Graph Contract

- Existing project documents remain the source of truth.
- Relationship notes may link to project documents; project documents do not need reciprocal edits.
- `MC 项目关系图.canvas` is the curated semantic view.
- Obsidian's global graph is the exploratory view.
- Prefer native Obsidian features over community plugins.

## Verification

- Before graph maintenance, record hashes for protected project documents.
- After graph maintenance, verify that those hashes are unchanged.
- Check all `_graph` wikilinks for existing targets.
- Validate `.canvas` and `.obsidian/*.json` as JSON before delivery.



## AI Navigation Contract

- The single vault entry point is `_graph/MC 项目总览.md` (alias: 总目录 / 总索引 / MOC / Home).
- Any AI or new session must read that page's "AI 阅读协议" and "任务路由表" before opening other files.
- Do not read the whole vault. Navigate master -> hub -> target section. Use `rg` with a narrow target only when routing fails.
- `useful_recipes_1.21.1_neoforge/` is an excluded zone: do not read, search, modify, or index it.
- When Markdown files are added or removed, run `_graph/tools/update-vault-index.ps1` and update the relevant `_graph` hub.
- Navigation maintenance stays inside `_graph`. Only vault-level `AGENTS.md`, `MEMORY.md`, and `.obsidian` configuration may be updated directly.
- `_graph/PROTECTED-FILES.sha256` records the protected project documents. Do not modify those documents for navigation purposes.
- Project source documents remain the source of truth; `_graph` pages are descriptive navigation only.
- Entry link: [[_graph/MC 项目总览|总目录]]

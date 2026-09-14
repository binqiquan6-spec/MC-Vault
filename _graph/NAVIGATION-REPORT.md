---
graph_role: maintenance
aliases: [导航报告]
---

# 导航体系建设报告（2026-09-14）

## 目标

让 AI 和人都从 `_graph/MC 项目总览.md` 开始阅读，按任务路由表跳到目标章节，避免每次通读全部上下文。

## 已完成

- P0-6：仓库外备份（受沙箱限制，位于 `.nav-backup/Vault-20260914-133349`，591 个文件 / 72.3 MB）与 116 个 md 的 SHA256 清单。
- P0-4：9 条受保护文档哈希基线重建；6 条历史不匹配已获用户确认。
- 方案 A：13 个项目文档正文保持不变，导航层只存在于 `_graph`。
- 总目录：AI 阅读协议、任务路由表、排除区、自动全量索引。
- AI 入口契约：根 `AGENTS.md` 的「AI Navigation Contract」、根 `MEMORY.md` 的导航决策。
- 排除区：`useful_recipes_1.21.1_neoforge/` 不索引、不读取、不修改；MC Canvas 中的相关节点已移除。
- 导航页：项目页、4 个领域页、周边项目与补丁入口、3 个无 md 项目包装页。
- 生成器：`build-entity-graph.ps1` 为 88 个实体页、4 个分类索引和实体总索引增加向上链；实体 Canvas 增加总目录节点。
- 索引：`update-vault-index.ps1` 自动生成总目录附录。
- 校验：`validate-vault-navigation.ps1` 检查入链、可达性、深度、断链、章节锚点、保护哈希；实体校验器已适配表格转义链接。
- MC 项目关系图：加入总目录、周边项目、工具清单与当前任务卡节点；移除 useful_recipes 节点。

## 待完成

- 运行 `_graph/tools/apply-obsidian-config.ps1`：写入 10 组图谱颜色、导航书签、启用 Folder Overview。必须先完全退出 Obsidian。
- 安装并启用 Obsidian Git 与 Homepage（可用 `obsidian://show-plugin?id=obsidian-git` 和 `obsidian://show-plugin?id=homepage`）。
- Folder Overview 已在 `.obsidian/plugins/folder-overview` 就位，待启用。
- Breadcrumbs 仅在副本 Vault 中试点，确认不写项目文件后再决定。
- 可选：在总目录/项目页加入 Folder Overview 动态索引代码块。
- 可选：初始化 Vault 根 Git 仓库并做首次提交（Obsidian Git 配置为手动提交，避免 E1-01 期间提交半成品）。

## 验收指标

- 参与处理的 md：119 个（另有报告页后为 120）。
- 排除：`useful_recipes_1.21.1_neoforge/`。
- 断链：0。
- 孤立文件：0。
- 总目录不可达：0。
- 最大跳转深度：1（总目录全量索引直达）。
- 章节锚点警告：0。
- 受保护文档哈希：PASS。
- 图谱颜色组：待 apply 脚本写入（目标 10）。

## 风险与边界

- E1-01 仍在 `IN_PROGRESS`；本次导航工作未写入 `bonded_companions/**`，不干扰项目开发。
- E1-01 完成时若更新受保护文档，哈希基线会再次过期，届时刷新即可。
- Obsidian Git 启用后先关自动提交；CI/自动备份等 E1-01 完成后再开。


## 2026-09-14 完成更新

- 10 组图谱颜色已写入 `.obsidian/graph.json`。
- 导航书签已写入 `.obsidian/bookmarks.json`（总目录、实体索引、PRD、Tech-Spec、STATUS、当前任务卡、两张 Canvas）。
- Folder Overview、Obsidian Git、Homepage 三个插件已安装并写入启用列表。
- 总目录已加入 Folder Overview 动态索引代码块（限定 `_graph` 与 `bonded_companions`）。
- Vault Git 仓库已初始化并完成首次提交：`8dee2f8 Initialize vault navigation system and knowledge base`（157 个文本文件，工作区干净）。
- Obsidian Git 保持手动模式（自动提交/推送间隔默认 0），不会在 E1-01 期间自动提交。


## 2026-09-14 补充配置

- Homepage `data.json` 已写入：`value = _graph/MC 项目总览`（不带 .md），`openOnStartup = true`；重启 Obsidian 后生效。
- 本地备份远程 `origin` 指向 `.nav-backup/git-remote.git`，并生成 `vault-backup-*.bundle` 完整历史备份。
- 由于工具沙箱禁止 Git 的 MSYS 子进程和 HTTPS，Shell 无法直接 push；Obsidian Git 插件或换到 GitHub 后可正常推送。
- 切换到 GitHub：在浏览器创建私有仓库后，把仓库 URL 提供给 AI，执行 `git remote set-url origin <url>` 即可；PAT 在 Obsidian Git 中配置。


## 2026-09-14 GitHub 远程配置

- `origin` 已切换为：`https://github.com/binqiquan6-spec/MC-Vault.git`
- 沙箱环境无法完成 GitHub HTTPS 推送（TLS/schannel 被限制），但远程地址已写入 `.git/config`。
- 推送方式：在 Obsidian 中执行命令面板 `Git: Push`，或使用左侧 Git 源码控制视图。
- 认证：GitHub 用户名 + Personal Access Token（PAT）；PAT 不要提交到仓库，也不要发到聊天中。

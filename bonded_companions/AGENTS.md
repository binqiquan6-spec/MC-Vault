# Project Instructions

## Project

- Working title: Bonded Companions
- Target: Minecraft 1.21.1, NeoForge 21.1.x, Java 21
- Primary test pack: 希望与绝望-惊变100天 / 机械动力-冒险加强版
- Current phase: milestone-one technical prototype under an execution freeze after gate E0. The next permitted implementation task is `E1-01` in `DEVELOPMENT-EXECUTION-PLAN.md`; full v1 gameplay is not release-complete.

## Safety and Scope

- Develop only inside this project directory. Never edit the live modpack instance directly.
- Build a JAR in the project workspace, then copy it into a disposable clone of the pack for integration tests.
- Preserve unrelated user files and mods. Never replace or repackage third-party JARs.
- Do not add cat gameplay in v1 unless a safe Create: Meowchanics integration boundary is proven.
- Do not patch Horseman's menu or assume fixed slot indices.

## Product Rules

- Whitelist always overrides blacklist. The owner is implicitly whitelisted.
- Sitting, waiting, recall, air safety, and return-to-zone behavior override attack orders.
- Alt + Right Click opens management for owned supported creatures. Taming never uses Alt.
- Inventories and combat decisions are server-authoritative, including integrated singleplayer.
- Equipment slots must remain inaccessible to hopper/Create automation; only cargo may be exposed through the Cargo Hitching Post.
- Blank point 12 in the design conversation is intentionally left blank; do not invent a feature for it.

## Architecture

- Prefer NeoForge capabilities, data components, attachments, tags, and payloads over mixins.
- Use a mixin only when no supported event/API path exists, scope it to one stable call site, and document the exact target and fallback.
- Persist portable item contents on the item stack through data components.
- Persist per-entity ownership, mode, cooldowns, and references through attachments or vanilla-compatible entity data.
- Treat registry IDs, UUIDs, and names as separate concepts. Never identify a player or named entity by display name alone.
- Centralize combat rule resolution so every supported companion uses the same precedence rules.
- Only implement compatibility explicitly requested for Create, Horseman, Carry On, Modular Golems, Create: Meowchanics, and Jade. Keep all integrations optional and soft-failing; do not add speculative adapters for other mods during the current development phase.

## Coding Standards

- Use English for package names, identifiers, source comments, commit messages, and technical code documentation.
- Use Chinese for in-game text because this product targets a Chinese modpack; keep translation keys ready for localization.
- Keep classes focused and prefer composition over broad inheritance or duplicated AI logic.
- Avoid speculative abstractions and new dependencies. Reuse Minecraft and NeoForge systems first.
- Validate every client payload on the server: ownership, distance, entity state, slot legality, and rate limits.
- Never trust a client-reported target, item count, inventory index, or modifier-key state by itself.
- Use resource/data-driven tags for target defaults, equipment eligibility, and compatibility exceptions where practical.

## Documentation Contract

- PRD.md is the gameplay source of truth.
- Tech-Spec.md is the implementation and compatibility source of truth.
- ART-DIRECTION.md is the visual source of truth for item textures, equipment layers, palettes, and model silhouettes.
- RECIPES.md is the crafting and acquisition source of truth.
- DEVELOPMENT-RULES.md defines the development lifecycle and release gates.
- DEVELOPMENT-EXECUTION-PLAN.md defines the current task order, allowed tools, exploration limits and per-task gates.
- MEMORY.md records durable decisions, corrections, compatibility findings, and unresolved risks.
- If behavior changes, update all affected documents in the same change.

## Verification

Before calling an implementation complete, run the strongest applicable checks:

1. Gradle build and automated tests.
2. Dedicated game-test world or GameTests for targeting, persistence, damage, and inventory rules.
3. Manual client checks for screens, hit regions, modifier keys, animations, and item rendering.
4. Integration checks in a cloned pack for the explicitly requested set: Carry On, Create, Horseman, Modular Golems, Create: Meowchanics, and Jade. Unnamed mod-specific compatibility is deferred until a real conflict is reproduced.
5. Save/reload, dimension travel, death/drop, chunk unload, and corrupted/legacy data checks.

Current verification commands:

- `./gradlew test build --no-daemon`
- `./gradlew runData --no-daemon`

The checked-in wrapper uses a checksum-pinned Gradle 9.2.1 distribution. A small Maven metadata POM under `gradle/local-maven` keeps NeoForge dependency resolution reproducible on the target development network; it contains dependency coordinates only, not third-party binaries.

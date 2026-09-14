# Implementation Status

Last updated: 2026-09-14

This file separates code that exists from the complete v1 contract in `PRD.md`. A checked item means the implementation is present and has passed the verification listed below; it does not mean the behavior has completed in-game acceptance.

## Current Execution Gate

- Execution gate E0 is complete. Task `E1-01` is the sole `IN_PROGRESS` task: companion attachment save/load regression coverage.
- Final art, the full six-mod compatibility matrix, 209-mod target-pack testing, performance profiling and release packaging are not Core Alpha gates.
- Candidate tools in the workspace research list are not installed or used unless the active task card explicitly permits them.

## Implemented

- [x] NeoForge 21.1.x / Minecraft 1.21.1 / Java 21 project, distributable JAR, versioned data components and entity attachments.
- [x] Central target policy with absolute whitelist precedence, default hostile rules, spider inclusion, boss/neutral exclusions and final damage cancellation.
- [x] Left Alt + Right Click request path with owner, distance, line-of-sight, life-state, Shift and rate-limit validation.
- [x] Species management screen with entity preview, visible state, named equipment rows, slot hints, mode/petting controls, embedded ledger editor and golem center/radius controls.
- [x] Bonding and observable follow/defend behavior for the custom-owned species, plus optional Jade owner/mode display.
- [x] Two creative tabs and all 31 specified custom enchantment definitions, equipment applicability, exclusivity sets, runtime handlers, treasure loot and specified villager trades.
- [x] Axolotl bucket round-trip persistence and controlled fox attack path through version-locked minimal mixins.
- [x] Portable cargo menus, horse real saddle-slot storage, species capacities, mule ghost filters, local cargo hit regions and menu/automation race lock.
- [x] Cargo Hitching Post block entity with stable carrier identity, redstone lock, item-handler proxy, comparator output and standard block-capability boundary for hopper/Create access.
- [x] Snow Golem and Iron Golem now have separate four-level equipment lines. Cross-equipping is rejected; base armor/toughness, Snow Golem health/melt reduction and Iron Golem damage reduction use the correct species line.
- [x] Iron-only Fortress/Charged Blow/Reactive Plating and Snow-only Ember Snow/Deep Freeze/Rapid Volley applicability. The two enchantment families cannot leak through the old shared tag.
- [x] Hidden prototype item IDs migrate installed old reinforcement stacks to the correct species item while preserving stack components.
- [x] Component-preserving shaped upgrades carry name, enchantments and proportional remaining durability through both golem lines and the ram-headpiece upgrade; vanilla smithing handles Netherite stages.
- [x] Updated recipes, translations, tags, gameplay specifications, technical specifications and art handoff counts for the eight golem items.
- [x] Development-only in-memory GameTest harness with nine runtime checks for whitelist damage protection, golem radius enforcement, portable cargo reopening, one-time equipment drops, Axolotl bucket persistence, Heatproof Pannier input rejection, species-specific golem equipment, component-preserving upgrades and empty-slot codecs.
- [x] Companion and cargo persistence use the optional ItemStack codec, so normal empty equipment/inventory slots serialize instead of causing the entire attachment write to fail.

## Current P0 Release Blockers

- [ ] Expand runtime coverage for the complete default-hostile matrix, actual golem navigation back to center, chunk unload/reload, dimension travel, full cargo recovery from malformed legacy data and every custom enchantment.
- [ ] Perform manual client acceptance for management screens, ledger editing, petting feedback, cargo hit regions, every enchantment effect and every recipe.
- [ ] Verify equipment removal, entity death, chunk unload and dimension travel cannot duplicate or silently delete item-backed inventories under real gameplay timing.
- [ ] Verify the six explicitly requested optional integrations in disposable instances: Carry On, Create, Horseman, Modular Golems, Create: Meowchanics and Jade. Unnamed mod-specific compatibility is outside the current production scope.
- [ ] Replace or supply final item models, textures and entity equipment rendering only after the user provides the new visual template. Existing generated art remains ignored and visual production is frozen.
- [ ] Run balance and performance passes with representative companion counts in a cloned target pack.

## Verification Completed

- `gradlew test build --no-daemon`: passed on 2026-09-14.
- Unit tests passed for target precedence, combat formulas and proportional durability transfer, including malformed damage clamping.
- `gradlew runGameTestServer --no-daemon`: all 9 required GameTests passed on 2026-09-14; the server also completed world saving without attachment serialization errors.
- Runtime recipe checks confirm that the Heatproof Pannier accepts an empty Pet Satchel and rejects a filled one, and that a golem shaped upgrade preserves its custom name while scaling durability damage.
- `gradlew runData --no-daemon`: passed on 2026-09-14; NeoForge initialized the mod, all five mixins applied and the new recipe serializer registered without a loading error.
- All 125 checked-in JSON resources parse successfully.
- Packaged JAR inspection confirmed the golem split classes, eight recipes, two species enchantability tags and component-preserving recipe serializer are present.

## Known Limits

- The eight new golem item IDs intentionally have no newly produced visual assets while the art freeze is active; a client will not pass final resource/render acceptance until the user-supplied template is available.
- GameTests now verify selected server-side recipes and gameplay paths, but not client interaction geometry, real chunk/dimension timing, the complete enchantment matrix or target-pack compatibility.
- The earlier target-pack run reached player login but ended in an unrelated 1.9 GB heap `OutOfMemoryError`; it is not counted as a compatibility pass.
- The `0.1.0` artifact remains a development prototype and has not been copied into the live modpack.

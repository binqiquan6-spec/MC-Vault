# Project Memory

Last updated: 2026-09-14

## Implementation Baseline

- A NeoForge ModDevGradle project now exists for Minecraft 1.21.1, NeoForge 21.1.250, and Java 21. The current artifact version is 0.1.0.
- Core registration, persistence codecs, central target precedence, custom management/cargo screens, equipment and cargo systems, Hitching Post capability, 31 enchantments, recipes, translations, bonding AI and optional Jade display are implemented at prototype level.
- `gradlew test build --no-daemon`, `gradlew runData --no-daemon`, and all 9 required tests in `gradlew runGameTestServer --no-daemon` passed on 2026-09-14. Runtime coverage includes whitelist damage, golem target radius, cargo reopening, equipment death/drop, Axolotl bucket round trip, Heatproof Pannier input rejection, golem cross-equipping, component-preserving upgrades and empty-slot codec round trips. This still does not prove client gameplay or modpack compatibility.
- The current artifact is explicitly a technical prototype, not complete v1. `IMPLEMENTATION-STATUS.md` is the authoritative code-coverage and release-blocker checklist.
- Five narrowly scoped mixins are present: animal-armor enchanting/value, Axolotl bucket persistence, bonded Fox controlled attack and Horse Pack Chest saddle persistence. Each exists because the required vanilla boundary has no complete NeoForge event path; no third-party mod class is mixed into.
- The target development network cannot reliably reach the official NeoForged Maven. The build rewrites only that host to ForgeCDN and includes Mojang-derived dependency-coordinate metadata under `gradle/local-maven`; no third-party binaries are vendored.
- Visual production is frozen until the user provides a new template. Existing generated images, previews, GUI icons and previously labelled approved concepts are non-authoritative and must not be edited, reused or treated as references. The eight new golem item IDs intentionally have no new models/textures during this freeze.
- Persisted equipment and cargo slot lists must use `ItemStack.OPTIONAL_CODEC`; `ItemStack.CODEC` rejects empty slots and previously caused the entire companion attachment write to fail during world saving.
- Development progress is no longer managed by an overall completion percentage or broad hour estimate. `DEVELOPMENT-EXECUTION-PLAN.md` is the execution authority: one evidence-backed task may be `IN_PROGRESS`, and the current target is a narrow internal Core Alpha.
- Workspace tool research is candidate evidence, not an installation plan. Existing Gradle/JUnit/GameTest/datagen and local sources are the default path. Prism is deferred to isolated compatibility testing; packwiz is deferred until a baseline must be repeatedly rebuilt or shared; spark/MAT, Crash Assistant and NBT editors are incident tools only.
- `modlens-mcp` must not be a persistent default integration. Its Node 22 + Docker + PostgreSQL setup and approximately 3,400-token-per-turn default MCP schema overhead conflict with the project's current efficiency goal. If a named-mod compatibility problem cannot be solved from logs, public source or a single-JAR decompile, use only a one-shot CLI scope for that target.

## Environment

- Target game: Minecraft 1.21.1.
- Loader baseline observed in the target pack: NeoForge 21.1.228.
- Java baseline: Java 21.
- Important installed mods observed: Create 6.0.10, Carry On 2.2.2.11, Horseman 1.5.9, Create: Meowchanics 2.0.4 (mod id laowu), and Modular Golems 3.1.33.
- The live pack is outside this workspace. Work must remain in this project and be tested against a clone.

## Durable Product Decisions

- Management input is Left Alt + Right Click. Carry On keeps Shift + Right Click.
- Modifier state is detected client-side and sent as a small request; the server validates and performs the action.
- Taming never uses Alt and uses normal right click with food distinct from each creature's breeding food.
- Whitelist is absolute. Owner is always implicitly whitelisted. White rules beat all black rules.
- Rules support player UUID, creature type registry ID, and named entity UUID plus a name snapshot.
- Hostile monsters are blacklisted by default. Normal and cave spiders are included even when neutral in daylight. Neutral mobs are not automatically blacklisted. Warden, Wither, and Ender Dragon are not automatic targets. Creepers are automatic targets, with an explicit melee-pet risk warning.
- Cats, parrots, and allays are outside v1. Cat support is deferred because Create: Meowchanics deeply changes cat AI, equipment, rendering, and progression.
- During the current production phase, proactive compatibility work is limited to the user-named set: Create, Carry On, Horseman, Modular Golems, Create: Meowchanics and Jade. Do not create speculative adapters for other mods; reproduce a real conflict first and defer it to integration triage.

## Durable Visual Decisions

- `ART-DIRECTION.md` remains the requirements ledger, but no existing image, texture, GUI icon, model, preview, generated concept or directory labelled `approved` is a visual source of truth.
- Visual production is fully frozen until the user supplies a new template. Do not create, edit, delete, replace, trace or reuse visual assets during this freeze.
- The current content list contains 31 non-block inventory items plus the Cargo Hitching Post block item. Snow Golem and Iron Golem require eight distinct item identities and mounted structures, but their final silhouettes and material language are not approved yet.
- When work resumes, the new template must be translated into readable Minecraft-style inventory silhouettes at actual GUI size; neither the rejected miniature set nor the rejected over-simplified redraw may be used as a starting point.
- Functional constraints remain: Fox mouth equipment uses the vanilla held-item path, wearable layers do not replace creature body models, and cargo hit regions are frozen only after final geometry receives in-game screenshot and ray-hit verification.

## Companion Decisions

- Wolf slots: Target Ledger, Spiked Collar, vanilla Wolf Armor body slot, Pet Satchel.
- Wolf Armor never receives Thorns. Spiked Collar supplies the thorns behavior.
- Loyal Guard and Last Stand are mutually exclusive. During Last Stand protection, the wolf may still attack but has -50% final attack damage and -20% final movement speed.
- Axolotl slots: Target Ledger and Axolotl Harness. Proposed bonding food is a raw Tropical Fish item; bucketed tropical fish remains breeding food.
- Fox slots: Target Ledger, Fox Mouth, Lapis Talisman, Pet Satchel. Foxes have no Spiked Collar.
- Foxes are tamed with raw chicken. Vanilla berries remain breeding food.
- A fox holding an ordinary non-exclusive weapon deals 0.5 times its complete calculated normal non-smash attack. There is no unarmed-damage floor in the frozen specification. Direct damage enchantments do not work in a fox's mouth.
- Latest correction: a fox using a vanilla Mace deals 0.7 times the complete normal non-smash attack damage, not merely 0.7 times the weapon bonus. It also moves 30% slower and cannot use smash, Density, Breach, or Wind Burst effects.
- Moonfang Blade damage in a player's hand is +3 for every material. Fox values are Iron +3, Gold +4, Diamond +5.5, Netherite +7. Durability is 70% of the matching sword.
- Golems retain the Target Ledger. Their Control Core stores center coordinates, dimension, activity radius and mode. Each golem still has one modular equipment slot, not a full armor suit, but the accepted items are now species-specific.
- Control Core item data is the single persistent source for golem center, radius, mode, owner, and bound golem UUID; the entity attachment must not duplicate the activity area.
- Snow Golem line: Insulated Wrap, Iron Brace, Diamond Frost Plate and Netherite Core Plate. Iron Golem line: Leather Padding, Iron Reinforcement Plate, Diamond Reinforcement Plate and Netherite Reinforcement Plate. Cross-equipping and cross-species custom enchantments are rejected.
- Both lines use 256/512/1024/1536 durability and +2/+4/+6/+8 armor; Diamond/Netherite add +1/+2 toughness. Snow equipment adds +4/+8/+12/+16 maximum health and reduces environmental melting by 25%/50%/75%/90%. Iron equipment reduces remaining damage by 5%/10%/15%/20% instead of adding knockback resistance.
- Old prototype shared reinforcement IDs remain hidden only for save migration. Installed stacks are converted to the matching species item with components preserved.
- Iron and Diamond crafting upgrades use the component-preserving shaped recipe, retaining name, enchantments and proportional remaining durability. Netherite upgrades use vanilla smithing, which preserves base components.

## Transport Decisions

- Horse, Donkey, Mule, Camel, and Strider support cargo; they do not use target ledgers.
- A Horse Pack Chest occupies the saddle position, provides 18 slots, and makes the horse completely unrideable while installed.
- Horse cargo opens only through the upper-back cargo hit region, not the normal mounting hit region.
- Donkey uses a 27-slot Pack Frame, Mule an 18-slot Sorting Pannier with three filters, Camel a 36-slot Caravan Rack with one passenger seat disabled, and Strider an 18-slot Heatproof Pannier.
- Cargo equipment keeps its contents when removed and drops as one container item on death. Nested mod cargo is forbidden.
- The Heatproof Pannier recipe uses NeoForge's data-component ingredient. A runtime GameTest now confirms that an empty Pet Satchel is accepted and a filled one is rejected.
- The Cargo Hitching Post is the only automation exchange point. It exposes docked cargo as a block item handler to hoppers and Create logistics while keeping creature equipment private.
- Horseman compatibility must avoid menu replacement and fixed slot assumptions.

## Latest Strider Correction

- Thermal Jacket removes the dry-land cold/shiver and movement penalty but does not grant water or rain immunity.
- Heatstride I/II gives +5%/+10% movement on dry land and doubles its own bonus on or in lava to +10%/+20%.

## Compatibility Findings

- The first live-pack launch with Bonded Companions 0.1.0 reached player login on NeoForge 21.1.228 and produced no Bonded Companions WARN/ERROR/exception lines. The client then exhausted its 1.9 GB Java heap during resource/JEI/Distant Horizons work; Distant Horizons reported insufficient memory and several threads ended with `OutOfMemoryError`. This run is not a valid gameplay compatibility pass, but it confirms mod discovery and initial world join.
- NeoForge provides distinct item-handler capabilities for entities, automation, and blocks. This supports keeping creature cargo manual while exposing only the Hitching Post as block automation.
- Create Mechanical Arm discovers block item handlers, so the Hitching Post can integrate without changing Create internals.
- Create Portable Storage Interface is for contraptions and is not the correct animal-cargo boundary.
- Horseman modifies horse screens/menus and adds a lead slot; compatibility should use vanilla/entity capability boundaries rather than editing its menu.
- Create: Meowchanics has broad cat AI, inventory, filter, combat-career, and rendering modifications and no clear public API found during inspection. Cat support therefore remains deferred.

## Open Decisions for Playtesting

- Exact economy and recipe costs are initial balance baselines until tested inside the 209-mod pack.
- Exact fox non-exclusive weapon calculation needs an automated damage matrix to confirm Minecraft attribute/enchantment ordering.
- Axolotl bonding chance and all new taming chances use a proposed one-in-three baseline unless otherwise stated.
- Final mod name, namespace, textures, sounds, and translations are not locked.

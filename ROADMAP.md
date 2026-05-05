# Roadmap

Rough, optimistic ordering. Each item is a self-contained increment that should land in its own PR.

## Milestone 0 — MVP scaffold (this PR)

- [x] Godot 4 project skeleton, autoloads, scene router.
- [x] Settings screen with H3 install path picker.
- [x] Adventure map with placeholder graphics, A* pathfinding, resources, monsters, goal flag.
- [x] Hex-grid battlefield with move / attack / wait / defend + simple enemy AI.
- [x] Damage formula approximating the original.
- [x] CI: gdtoolkit lint + headless project import smoke test.

## Milestone 1 — Real H3 asset loading

- [ ] `.lod` archive parser (binary format, well documented).
- [ ] `.pcx` static image decoder.
- [ ] `.def` animated sprite decoder (palette + frame table).
- [ ] Wire `AssetLoader.get_terrain_tile` / `get_creature_sprite` to real assets when the user has configured an H3 path.
- [ ] CRTRAITS.TXT / HOTRAITS.TXT parser to populate `CreaturesDB` from the original game.

## Milestone 2 — Towns and economy

- [ ] Town scene with build queue and creature dwellings.
- [ ] Recruitment from dwellings.
- [ ] Income from town buildings (resource silos, market, etc.).
- [ ] At least one faction implemented end-to-end (Castle).

## Milestone 3 — Combat depth

- [ ] Full creature roster for the implemented faction.
- [ ] Special abilities (double attack, fire breath, etc.).
- [ ] Spell system: spellbook, casting cost, school / level.
- [ ] Hero secondary skills affecting combat.

## Milestone 4 — Adventure map depth

- [ ] `.h3m` map file parser.
- [ ] Multiple owned heroes per player.
- [ ] Strategic AI for AI opponents.
- [ ] Mines, dwellings, scrolls, shrines and the rest of the object catalogue.

## Milestone 5 — Polish & multiplayer

- [ ] Save / load.
- [ ] Hot-seat multiplayer.
- [ ] Network multiplayer (lockstep or rollback).
- [ ] Full campaign support.

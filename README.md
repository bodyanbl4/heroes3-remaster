# Heroes 3 Remaster

An open-source engine remake of *Heroes of Might and Magic III* (3DO/New World Computing, 1999) built with [Godot 4](https://godotengine.org/).

This repository contains **only original code and programmatically generated placeholder graphics**. It is an *engine reimplementation*: it is designed to load the user's own legitimately-purchased Heroes 3 install (the same approach taken by [VCMI](https://vcmi.eu/) and [OpenMW](https://openmw.org/)). No copyrighted assets from Heroes 3 are bundled, will be bundled, or are required for development.

> **Status: pre-alpha MVP.** This is a tiny vertical slice — adventure-map traversal and a simplified hex-grid battle. Most of the original game (towns, magic, AI strategy, campaigns, multiplayer) is not yet implemented. See [ROADMAP.md](ROADMAP.md).

## What works in the MVP

- **Main menu / Settings / Game flow** (Godot scenes wired through a `SceneRouter`).
- **Adventure map**: 30×20 tile grid, 4-directional + diagonal A* pathfinding (`AStarGrid2D`), click-once-to-plot / click-again-to-confirm movement, movement-point budget, 7-resource economy, day/turn cycle.
- **Map objects**: pickable resource piles (gold, wood, ore), neutral monster stacks, and a goal flag.
- **Combat**: 11×15 hex battlefield, speed-based turn order, move / attack / wait / defend, melee retaliation, ranged shots, simple greedy enemy AI. Damage formula approximates the original.
- **Asset loader stub** with a runtime detector for an H3 install (looks for `Data/H3bitmap.lod` and `Data/H3sprite.lod`). When the user has not configured a path, the game generates placeholder textures so it remains playable.
- **CI**: `gdtoolkit` lint + headless project import smoke test.

## What does **not** work yet

- Towns, town building, hero recruitment.
- Magic, spells, secondary skills, artifacts.
- Real `.lod`/`.def`/`.pcx`/`.h3m` parsers — the slots exist in `AssetLoader`, but no real format reader is implemented.
- Strategic AI for the opponent on the adventure map (battles use a tactical AI; the strategic layer is still placeholder).
- Save/load, campaigns, multiplayer.

## Running locally

1. Install [Godot 4.3](https://godotengine.org/download/) (other 4.x versions probably work but are not tested in CI).
2. Clone this repo.
3. Open `project.godot` in the Godot editor, or run `godot --path .` from the command line.
4. Press **F5** in the editor (or click "New Game" in the main menu) to start.

The first run will also work entirely offline with placeholder graphics. To use original H3 graphics later (when the parsers are implemented):

1. Copy your legally-owned Heroes 3 installation directory anywhere on disk.
2. In the in-game **Settings** screen, point "Heroes 3 install directory" at it (the directory containing `Data/H3bitmap.lod`).
3. Save and start a new game.

## Project layout

```
project.godot              Godot 4 project descriptor + autoloads
scenes/                    .tscn files for each top-level screen
scripts/
  autoload/                Singletons (GameState, AssetLoader, SettingsManager, ...)
  data/                    Pure-data classes and lookup tables (Tile, CreaturesDB)
  adventure/               Adventure-map gameplay (map gen, pathfinder, scene)
  battle/                  Hex grid + battlefield gameplay
  ui/                      Menu / settings scripts
  assets/                  (reserved) format-specific loaders for .lod / .def / .pcx
.github/workflows/         CI: lint + headless project import
```

## Architecture notes

- **Autoloads** (`GameState`, `SettingsManager`, `AssetLoader`, `SceneRouter`, `BattleSetup`, `CreaturesDB`) handle cross-scene state. `BattleSetup` is the input bag for `Battlefield`; `GameState.last_battle_result` is the output bag read by `AdventureMap` after combat.
- `AssetLoader` detects whether to use original H3 files or programmatically-generated placeholders. When a real `.lod`/`.def`/`.pcx` parser is added, it will plug into `get_terrain_tile()` and `get_creature_sprite()` without changes elsewhere.
- The damage formula lives in `scripts/battle/damage.gd`, separated from `BattleUnit` so it can be unit-tested without instantiating a full battlefield.
- Pathfinding wraps Godot's `AStarGrid2D` so we get optimised C++ A* rather than implementing it in GDScript. Hex distance for the battlefield uses cube-coordinate conversion.

## Legal

This project is licensed under [GPL-3.0](LICENSE). It contains **no** assets owned by 3DO, New World Computing, or Ubisoft. To see Heroes 3's original art and audio in the game, the user must own a copy of Heroes 3 and provide it themselves at runtime — same model as VCMI or OpenMW.

If you are an IP holder and believe any code in this repository reproduces protected material, please open an issue and we will address it.

## Contributing

Issues and PRs welcome — but please understand the scope: a full HoMM3 remake is years of work, and at the moment we are at week 1 day 1. Small contributions (creature stat parsers, terrain renderers, single map objects) are the most likely to land.

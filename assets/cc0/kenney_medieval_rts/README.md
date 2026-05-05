# Kenney — Medieval RTS

Sprite pack used as the in-game placeholder graphics. All assets in this folder
are taken from [Kenney's Medieval RTS pack](https://kenney.nl/assets/medieval-rts).

## License

Creative Commons Zero (CC0). Public domain — no rights reserved. The pack
ships with the original `LICENSE.txt` from Kenney in this directory.

Credit ("Kenney" / `www.kenney.nl`) is not mandatory but is given anyway in
the project's top-level `README.md`.

## Layout

- `tiles/` — 58 terrain tiles (grass, sand, water, paths, snow) at 64×64 px.
  Default tile mapping in `scripts/autoload/asset_loader.gd`.
- `units/` — 24 unit sprites in four faction colours (blue, red, green, orange).
- `structures/` — 23 buildings (towers, mills, watchtowers, castles).
- `environment/` — 21 props (trees, rocks, sacks, fires).

## Usage

`AssetLoader.get_terrain_tile(StringName)` reads from `tiles/` based on the
mapping table at the top of `asset_loader.gd`. The same loader exposes
`get_environment_sprite()` and `get_unit_sprite()` for the other folders.

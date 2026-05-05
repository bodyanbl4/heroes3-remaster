extends Node
## Loads sprites, sounds and data tables.
##
## Three sources are supported, in order of preference:
##
## 1. Original Heroes of Might and Magic III archives, if the user pointed
##    SettingsManager at a real H3 install. Parsing of `.lod`/`.def`/`.pcx`
##    is wired up incrementally — see `ROADMAP.md`. We never bundle
##    copyrighted H3 assets in this repository.
##
## 2. Bundled CC0 fallback art (Kenney's "Medieval RTS" pack, public domain).
##    Lives under `assets/cc0/kenney_medieval_rts/`. Used when there is no H3
##    install or while real-asset parsers are still in flight.
##
## 3. Procedural placeholders generated at runtime as a last-resort fallback
##    so CI and headless tests never break on a missing file.

const PLACEHOLDER_TILE_SIZE: int = 64
const PLACEHOLDER_HEX_RADIUS: int = 32

## Folders inside `res://assets/cc0/kenney_medieval_rts/`.
const KENNEY_TILES_DIR: String = "res://assets/cc0/kenney_medieval_rts/tiles"
const KENNEY_UNITS_DIR: String = "res://assets/cc0/kenney_medieval_rts/units"
const KENNEY_ENV_DIR: String = "res://assets/cc0/kenney_medieval_rts/environment"
const KENNEY_STRUCT_DIR: String = "res://assets/cc0/kenney_medieval_rts/structures"

## Folders inside `res://assets/ai_generated/` — original AI-generated art for
## the Halendor world. See `LORE.md` Section 4 for the prompt index and the
## generation workflow.
const AI_UNITS_DIR: String = "res://assets/ai_generated/units"
const AI_ICONS_DIR: String = "res://assets/ai_generated/icons"
const AI_BACKDROPS_DIR: String = "res://assets/ai_generated/backdrops"
const AI_HEROES_DIR: String = "res://assets/ai_generated/heroes"

## Per-creature AI sprite filenames. Keys match the unit names shown in the
## battle log (CreaturesDB.UNITS) and the LORE.md Dawn-faction roster. When a
## creature has no AI art yet the loader falls back to the faction-coloured
## Kenney token.
const AI_UNIT_SPRITES: Dictionary = {
	"Pikeman": "pikeman.png",
	"Crossbowman": "crossbowman.png",
	"Squire": "squire.png",
	"Griffin": "griffin.png",
	"Monk": "monk.png",
	"Cavalier": "cavalier.png",
	"Angel": "angel.png",
	# Aliases for the placeholder names still used in the old battle setup
	# (CreaturesDB returns "Archer" / "Swordsman" — map them to the Halendor
	# canonical Crossbowman / Squire so the AI art shows up immediately).
	"Archer": "crossbowman.png",
	"Swordsman": "squire.png",
}

## Resource icons keyed by GameState.RESOURCES.
const AI_RESOURCE_ICONS: Dictionary = {
	"gold": "gold.png",
	"wood": "wood.png",
	"ore": "ore.png",
	"crystal": "crystal.png",
	"mercury": "mercury.png",
	"sulfur": "sulfur.png",
	"gems": "gems.png",
}

## Hand-picked Kenney tiles for each Tile.Terrain. The pack has 58 tiles; we
## chose the ones that look "pure" (no road, no border decoration) so the map
## reads cleanly. Variants per terrain enable subtle visual variation.
const KENNEY_TERRAIN_TILES: Dictionary = {
	&"grass": ["medievalTile_57.png", "medievalTile_58.png"],
	&"dirt": ["medievalTile_13.png"],
	&"sand": ["medievalTile_02.png"],
	&"water": ["medievalTile_28.png"],
	&"rock": ["medievalTile_15.png"],
	&"tree": ["medievalTile_42.png", "medievalTile_44.png"],
}

## Faction-coloured unit sprites. Index by faction colour; each entry is a
## representative knight token used on the adventure map / battle field.
const KENNEY_UNITS_BY_FACTION: Dictionary = {
	"blue": "medievalUnit_01.png",
	"red": "medievalUnit_09.png",
	"green": "medievalUnit_13.png",
	"orange": "medievalUnit_18.png",
}

enum Source { ORIGINAL_H3, KENNEY_CC0, PLACEHOLDER }

var current_source: Source = Source.KENNEY_CC0

# Cached generated/loaded textures, keyed by descriptor.
var _cache: Dictionary = {}


func _ready() -> void:
	_refresh_source()
	SettingsManager.settings_changed.connect(_refresh_source)


func _refresh_source() -> void:
	var path: String = SettingsManager.h3_data_path
	if path.is_empty() or not _looks_like_h3_install(path):
		# Prefer Kenney CC0 over generated placeholders when the bundled
		# pack is present (which it always is in CI / a normal checkout).
		if _kenney_pack_present():
			current_source = Source.KENNEY_CC0
		else:
			current_source = Source.PLACEHOLDER
	else:
		current_source = Source.ORIGINAL_H3


## Returns true when the directory at `path` plausibly contains an H3
## installation. We look for a `Data/` subfolder with `.lod` archives — the
## standard layout shipped by 3DO/Ubisoft for both the original game and
## HD/HotA mods.
func _looks_like_h3_install(path: String) -> bool:
	var data_dir: DirAccess = DirAccess.open(path)
	if data_dir == null:
		return false
	# Accept either H3 root (with Data/ subfolder) or the Data/ folder itself.
	var candidates: Array[String] = [
		"Data/H3bitmap.lod", "Data/H3sprite.lod", "H3bitmap.lod", "H3sprite.lod"
	]
	for rel in candidates:
		if FileAccess.file_exists(path.path_join(rel)):
			return true
	return false


func _kenney_pack_present() -> bool:
	# The grass tile is required; if it's missing, the pack is broken and we
	# silently fall back to procedural tiles.
	return ResourceLoader.exists(KENNEY_TILES_DIR.path_join("medievalTile_57.png"))


## Returns a tile texture for an adventure-map terrain type. Picks a
## deterministic variant based on `variant` (typically row*width+col so the
## map looks stable across redraws but varied across tiles).
func get_terrain_tile(terrain: StringName, variant: int = 0) -> Texture2D:
	if current_source == Source.KENNEY_CC0:
		var tex: Texture2D = _load_kenney_terrain(terrain, variant)
		if tex != null:
			return tex
	# Procedural fallback.
	var key: String = "placeholder:terrain:%s" % terrain
	if _cache.has(key):
		return _cache[key]
	var color: Color = _color_for_terrain(terrain)
	var fallback: Texture2D = _make_solid_tile(color, PLACEHOLDER_TILE_SIZE)
	_cache[key] = fallback
	return fallback


func _load_kenney_terrain(terrain: StringName, variant: int) -> Texture2D:
	var variants: Array = KENNEY_TERRAIN_TILES.get(terrain, [])
	if variants.is_empty():
		return null
	var sprite_name: String = variants[variant % variants.size()]
	var key: String = "kenney:tile:%s" % sprite_name
	if _cache.has(key):
		return _cache[key]
	var path: String = KENNEY_TILES_DIR.path_join(sprite_name)
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path) as Texture2D
	_cache[key] = tex
	return tex


## Returns a creature portrait/sprite by id. Used by combat HUD. Currently
## returns a coloured token; richer per-creature art arrives in a later PR.
func get_creature_sprite(creature_id: StringName, faction_color: Color) -> Texture2D:
	var key: String = "creature:%s:%s" % [creature_id, faction_color.to_html()]
	if _cache.has(key):
		return _cache[key]
	var tex: Texture2D = _make_creature_token(faction_color, PLACEHOLDER_HEX_RADIUS)
	_cache[key] = tex
	return tex


## Returns an AI-generated full-body sprite for a named creature, or null when
## the creature isn't in the AI roster yet. Caller is expected to fall back to
## `get_faction_unit_sprite()` for unknown creatures.
func get_ai_creature_sprite(creature_name: String) -> Texture2D:
	var fname: String = AI_UNIT_SPRITES.get(creature_name, "")
	if fname.is_empty():
		return null
	var key: String = "ai:unit:%s" % fname
	if _cache.has(key):
		return _cache[key]
	var path: String = AI_UNITS_DIR.path_join(fname)
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path) as Texture2D
	_cache[key] = tex
	return tex


## Returns an AI-generated icon for a resource id ("gold", "wood", ...). Falls
## back to a coloured square when the icon isn't available so the HUD always
## renders something.
func get_resource_icon(resource_id: String) -> Texture2D:
	var fname: String = AI_RESOURCE_ICONS.get(resource_id, "")
	if not fname.is_empty():
		var key: String = "ai:icon:%s" % fname
		if _cache.has(key):
			return _cache[key]
		var path: String = AI_ICONS_DIR.path_join(fname)
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path) as Texture2D
			_cache[key] = tex
			return tex
	# Procedural fallback: coloured square keyed by resource id so different
	# resources at least look distinct in headless tests.
	var fallback_color: Color = _color_for_resource(resource_id)
	return _make_solid_tile(fallback_color, 32)


## Returns an AI-generated backdrop by short name ("main_menu",
## "battlefield_grass"). Returns null when not present so the caller can apply
## a procedural fallback (e.g. solid colour).
func get_backdrop(name: String) -> Texture2D:
	var key: String = "ai:backdrop:%s" % name
	if _cache.has(key):
		return _cache[key]
	var path: String = AI_BACKDROPS_DIR.path_join("%s.jpg" % name)
	if not ResourceLoader.exists(path):
		return null
	var tex: Texture2D = load(path) as Texture2D
	_cache[key] = tex
	return tex


func _color_for_resource(resource_id: String) -> Color:
	match resource_id:
		"gold":
			return Color(0.95, 0.78, 0.22)
		"wood":
			return Color(0.55, 0.36, 0.20)
		"ore":
			return Color(0.55, 0.55, 0.60)
		"crystal":
			return Color(0.30, 0.65, 0.95)
		"mercury":
			return Color(0.85, 0.85, 0.92)
		"sulfur":
			return Color(0.95, 0.85, 0.25)
		"gems":
			return Color(0.85, 0.30, 0.55)
		_:
			return Color(0.5, 0.5, 0.5)


## Returns a faction-tinted Kenney unit sprite for use as a hero / squad
## token on the adventure map. Falls back to the procedural creature token
## when the CC0 pack isn't available.
func get_faction_unit_sprite(faction: StringName) -> Texture2D:
	var faction_str: String = String(faction)
	if current_source == Source.KENNEY_CC0:
		var sprite_name: String = KENNEY_UNITS_BY_FACTION.get(faction_str, "")
		if not sprite_name.is_empty():
			var key: String = "kenney:unit:%s" % sprite_name
			if _cache.has(key):
				return _cache[key]
			var path: String = KENNEY_UNITS_DIR.path_join(sprite_name)
			if ResourceLoader.exists(path):
				var tex: Texture2D = load(path) as Texture2D
				_cache[key] = tex
				return tex
	# Procedural fallback: use a coloured token in the requested faction
	# colour.
	var color: Color = _color_for_faction(faction_str)
	return _make_creature_token(color, PLACEHOLDER_HEX_RADIUS)


func _color_for_faction(faction: String) -> Color:
	match faction:
		"blue":
			return Color(0.35, 0.55, 0.95)
		"red":
			return Color(0.85, 0.25, 0.25)
		"green":
			return Color(0.30, 0.65, 0.35)
		"orange":
			return Color(0.95, 0.55, 0.20)
		_:
			return Color(0.6, 0.6, 0.6)


func _color_for_terrain(terrain: StringName) -> Color:
	match terrain:
		&"grass":
			return Color(0.36, 0.55, 0.24)
		&"dirt":
			return Color(0.55, 0.42, 0.27)
		&"sand":
			return Color(0.84, 0.74, 0.46)
		&"water":
			return Color(0.18, 0.32, 0.55)
		&"rock":
			return Color(0.32, 0.30, 0.28)
		&"tree":
			return Color(0.18, 0.32, 0.16)
		_:
			return Color(0.4, 0.4, 0.4)


func _make_solid_tile(color: Color, size: int) -> ImageTexture:
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(color)
	# Subtle border to make grid visible.
	var border: Color = color.darkened(0.2)
	for x in range(size):
		img.set_pixel(x, 0, border)
		img.set_pixel(x, size - 1, border)
	for y in range(size):
		img.set_pixel(0, y, border)
		img.set_pixel(size - 1, y, border)
	# A tiny noise pattern so adjacent tiles don't look totally flat.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = int(color.r * 1000.0) + int(color.g * 100.0) + int(color.b * 10.0)
	for _i in range(size * size / 16):
		var px: int = rng.randi_range(2, size - 3)
		var py: int = rng.randi_range(2, size - 3)
		var tinted: Color = color.lerp(border, 0.4)
		img.set_pixel(px, py, tinted)
	return ImageTexture.create_from_image(img)


func _make_creature_token(faction_color: Color, radius: int) -> ImageTexture:
	var size: int = radius * 2
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var center: Vector2 = Vector2(radius, radius)
	for y in range(size):
		for x in range(size):
			var d: float = Vector2(x, y).distance_to(center)
			if d <= float(radius) - 1.0:
				var t: float = clamp(d / float(radius), 0.0, 1.0)
				img.set_pixel(x, y, faction_color.lerp(faction_color.darkened(0.4), t))
			elif d <= float(radius):
				img.set_pixel(x, y, Color.BLACK)
	return ImageTexture.create_from_image(img)

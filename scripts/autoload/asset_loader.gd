extends Node
## Loads sprites, sounds and data tables.
##
## The engine remake works with original Heroes of Might and Magic III
## archives stored on the user's machine. The user supplies the path via
## SettingsManager. We never bundle copyrighted assets in this repository.
##
## When the H3 path is missing or invalid, we fall back to programmatically
## generated placeholder textures so development and CI can run without the
## original game.

const PLACEHOLDER_TILE_SIZE: int = 64
const PLACEHOLDER_HEX_RADIUS: int = 32

enum Source { ORIGINAL_H3, PLACEHOLDER }

var current_source: Source = Source.PLACEHOLDER

# Cached generated placeholder textures, keyed by descriptor.
var _placeholder_cache: Dictionary = {}


func _ready() -> void:
	_refresh_source()
	SettingsManager.settings_changed.connect(_refresh_source)


func _refresh_source() -> void:
	var path: String = SettingsManager.h3_data_path
	if path.is_empty() or not _looks_like_h3_install(path):
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


## Returns a tile texture for an adventure-map terrain type. When the user has
## supplied original H3 files, this would route to the LOD/DEF parser. For now
## we always generate a placeholder.
func get_terrain_tile(terrain: StringName) -> Texture2D:
	var key: String = "terrain:%s" % terrain
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var color: Color = _color_for_terrain(terrain)
	var tex: Texture2D = _make_solid_tile(color, PLACEHOLDER_TILE_SIZE)
	_placeholder_cache[key] = tex
	return tex


## Returns a creature portrait/sprite by id. Used by combat HUD. Always
## placeholder for now.
func get_creature_sprite(creature_id: StringName, faction_color: Color) -> Texture2D:
	var key: String = "creature:%s:%s" % [creature_id, faction_color.to_html()]
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var tex: Texture2D = _make_creature_token(faction_color, PLACEHOLDER_HEX_RADIUS)
	_placeholder_cache[key] = tex
	return tex


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

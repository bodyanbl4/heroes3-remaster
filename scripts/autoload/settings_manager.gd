extends Node
## Persists user-controlled settings to `user://settings.cfg`.
##
## The most important setting for the engine remake is `h3_data_path`: the
## directory containing the user's original Heroes of Might and Magic III
## installation (or its `Data/` subfolder with `.lod` archives).

const SETTINGS_PATH: String = "user://settings.cfg"

signal settings_changed

var h3_data_path: String = ""
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var fullscreen: bool = false


func _ready() -> void:
	load_from_disk()


func load_from_disk() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load(SETTINGS_PATH)
	if err != OK:
		# Missing file is expected on first run; just keep defaults.
		return
	h3_data_path = String(cfg.get_value("paths", "h3_data_path", ""))
	music_volume = float(cfg.get_value("audio", "music_volume", 0.7))
	sfx_volume = float(cfg.get_value("audio", "sfx_volume", 0.8))
	fullscreen = bool(cfg.get_value("display", "fullscreen", false))
	settings_changed.emit()


func save_to_disk() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("paths", "h3_data_path", h3_data_path)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	var err: int = cfg.save(SETTINGS_PATH)
	if err != OK:
		push_warning("Failed to save settings: %s" % err)
	settings_changed.emit()


func set_h3_data_path(path: String) -> void:
	h3_data_path = path.strip_edges()
	save_to_disk()

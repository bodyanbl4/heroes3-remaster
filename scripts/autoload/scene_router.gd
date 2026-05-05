extends Node
## Centralised scene transitions. Other code should call SceneRouter rather
## than touching `get_tree().change_scene_to_file` directly so that the set of
## scenes lives in one place.

const MAIN_MENU: String = "res://scenes/main_menu.tscn"
const SETTINGS: String = "res://scenes/settings.tscn"
const ADVENTURE_MAP: String = "res://scenes/adventure_map.tscn"
const BATTLEFIELD: String = "res://scenes/battlefield.tscn"


func go_main_menu() -> void:
	_change(MAIN_MENU)


func go_settings() -> void:
	_change(SETTINGS)


func go_adventure_map() -> void:
	_change(ADVENTURE_MAP)


func go_battlefield() -> void:
	_change(BATTLEFIELD)


func _change(path: String) -> void:
	var err: int = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Failed to load scene %s (err=%s)" % [path, err])

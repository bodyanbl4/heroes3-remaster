extends Control

@onready var new_game_button: Button = $Panel/VBox/NewGameButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var quit_button: Button = $Panel/VBox/QuitButton
@onready var version_label: Label = $VersionLabel
@onready var asset_status_label: Label = $Panel/VBox/AssetStatusLabel


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	version_label.text = (
		"Heroes 3 Remaster — %s" % ProjectSettings.get_setting("application/config/version", "dev")
	)
	_refresh_asset_status()
	SettingsManager.settings_changed.connect(_refresh_asset_status)


func _refresh_asset_status() -> void:
	if AssetLoader.current_source == AssetLoader.Source.ORIGINAL_H3:
		asset_status_label.text = (
			"Using original H3 assets from:\n%s" % SettingsManager.h3_data_path
		)
		asset_status_label.modulate = Color(0.7, 1.0, 0.7)
	else:
		asset_status_label.text = "No H3 install detected — using placeholder graphics.\nConfigure in Settings."
		asset_status_label.modulate = Color(1.0, 0.85, 0.5)


func _on_new_game() -> void:
	GameState.reset_for_new_game()
	SceneRouter.go_adventure_map()


func _on_settings() -> void:
	SceneRouter.go_settings()


func _on_quit() -> void:
	get_tree().quit()

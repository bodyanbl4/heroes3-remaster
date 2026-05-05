extends Control

@onready var path_input: LineEdit = $Panel/VBox/PathRow/PathInput
@onready var browse_button: Button = $Panel/VBox/PathRow/BrowseButton
@onready var save_button: Button = $Panel/VBox/Buttons/SaveButton
@onready var back_button: Button = $Panel/VBox/Buttons/BackButton
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var music_slider: HSlider = $Panel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SfxRow/SfxSlider

var _file_dialog: FileDialog


func _ready() -> void:
	path_input.text = SettingsManager.h3_data_path
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	browse_button.pressed.connect(_on_browse)
	save_button.pressed.connect(_on_save)
	back_button.pressed.connect(_on_back)
	_update_status()


func _update_status() -> void:
	if SettingsManager.h3_data_path.is_empty():
		status_label.text = "No H3 path set — placeholder graphics will be used."
		status_label.modulate = Color(1.0, 0.85, 0.5)
	elif AssetLoader.current_source == AssetLoader.Source.ORIGINAL_H3:
		status_label.text = "H3 install detected. Original assets will load when implemented."
		status_label.modulate = Color(0.7, 1.0, 0.7)
	else:
		status_label.text = "Path set, but H3bitmap.lod / H3sprite.lod not found inside."
		status_label.modulate = Color(1.0, 0.6, 0.5)


func _on_browse() -> void:
	if _file_dialog == null:
		_file_dialog = FileDialog.new()
		_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
		_file_dialog.use_native_dialog = true
		_file_dialog.dir_selected.connect(_on_dir_selected)
		add_child(_file_dialog)
	_file_dialog.popup_centered_ratio(0.7)


func _on_dir_selected(dir: String) -> void:
	path_input.text = dir


func _on_save() -> void:
	SettingsManager.set_h3_data_path(path_input.text)
	SettingsManager.music_volume = music_slider.value
	SettingsManager.sfx_volume = sfx_slider.value
	SettingsManager.save_to_disk()
	_update_status()


func _on_back() -> void:
	SceneRouter.go_main_menu()

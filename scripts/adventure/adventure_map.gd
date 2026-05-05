extends Node2D
## Adventure map: tile-based overworld where the player's hero moves day by
## day. Click any tile once to preview the path, click again to commit. The
## hero animates through the path, picks up resources, and triggers a battle
## when entering a tile occupied by a neutral monster stack.

const Tile := preload("res://scripts/data/tile.gd")
const MapGenerator := preload("res://scripts/adventure/map_generator.gd")
const AdventurePathfinder := preload("res://scripts/adventure/pathfinder.gd")

const TILE_SIZE: int = 64
const MAP_OFFSET: Vector2 = Vector2(20, 80)
const HERO_SPEED_PX_PER_SEC: float = 320.0

@onready var hud: CanvasLayer = $HUD
@onready var resources_label: Label = $HUD/Top/ResourcesLabel
@onready var day_label: Label = $HUD/Top/DayLabel
@onready var mp_label: Label = $HUD/Top/MovementLabel
@onready var end_turn_button: Button = $HUD/Top/EndTurnButton
@onready var menu_button: Button = $HUD/Top/MenuButton
@onready var status_label: Label = $HUD/Bottom/StatusLabel
@onready var map_camera: Camera2D = $MapCamera

var _grid: Array
var _pathfinder: AdventurePathfinder
var _pending_path: Array = []
var _hero_pixel_pos: Vector2 = Vector2.ZERO
var _is_moving: bool = false
var _move_index: int = 0
var _move_target_pixel: Vector2 = Vector2.ZERO
var _battle_target_tile: Vector2i = Vector2i(-1, -1)


func _ready() -> void:
	_grid = MapGenerator.generate()
	_pathfinder = AdventurePathfinder.new(_grid)
	_hero_pixel_pos = _tile_to_pixel(GameState.hero_tile)
	end_turn_button.pressed.connect(_on_end_turn)
	menu_button.pressed.connect(_on_menu_pressed)
	GameState.resources_changed.connect(_refresh_resources_label)
	GameState.hero_moved.connect(_refresh_mp_label)
	GameState.turn_advanced.connect(_refresh_day_label)
	_refresh_resources_label(GameState.resources)
	_refresh_mp_label(GameState.hero_tile, GameState.hero_movement_left)
	_refresh_day_label(GameState.current_day)
	_resolve_pending_battle_outcome()
	_recenter_camera_on_hero(true)
	queue_redraw()


## Center the camera on the hero. The first call after _ready snaps without
## smoothing so the player doesn't see a pan from the screen origin.
func _recenter_camera_on_hero(snap: bool = false) -> void:
	if map_camera == null:
		return
	if snap:
		map_camera.position_smoothing_enabled = false
		map_camera.position = _hero_pixel_pos
		map_camera.reset_smoothing()
		map_camera.position_smoothing_enabled = true
	else:
		map_camera.position = _hero_pixel_pos


## When returning from Battlefield, GameState.last_battle_result tells us
## what to do with the monster the player attacked.
func _resolve_pending_battle_outcome() -> void:
	var result: Dictionary = GameState.last_battle_result
	if result.is_empty():
		return
	var outcome: String = String(result.get("outcome", ""))
	var target: Vector2i = result.get("target_tile", Vector2i(-1, -1))
	if outcome == "victory" and target.x >= 0:
		var t: Tile = _grid[target.y][target.x]
		t.object_kind = Tile.ObjectKind.NONE
		t.monster_army = []
		t.monster_label = ""
		# Replace player's army with what survived combat.
		var survivors: Array = result.get("remaining_army", [])
		var typed: Array[Dictionary] = []
		for entry in survivors:
			typed.append((entry as Dictionary).duplicate(true))
		GameState.player_army = typed
		# Move hero onto the now-empty tile.
		GameState.hero_tile = target
		_hero_pixel_pos = _tile_to_pixel(target)
		_pathfinder.refresh()
		status_label.text = "Victory! You defeated the enemy and claim their territory."
	elif outcome == "defeat":
		GameState.reset_for_new_game()
		_grid = MapGenerator.generate()
		_pathfinder = AdventurePathfinder.new(_grid)
		_hero_pixel_pos = _tile_to_pixel(GameState.hero_tile)
		status_label.text = "Defeat! Your army was wiped out. Restarting..."
	GameState.last_battle_result = {}
	queue_redraw()


func _process(delta: float) -> void:
	if _is_moving:
		_advance_hero_movement(delta)
	if map_camera != null:
		map_camera.position = _hero_pixel_pos


func _input(event: InputEvent) -> void:
	if _is_moving:
		return
	if event is InputEventMouseButton and event.pressed:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(mb.position)
	elif event.is_action_pressed("ui_end_turn"):
		_on_end_turn()


func _handle_click(screen_pos: Vector2) -> void:
	var tile_coord: Vector2i = _pixel_to_tile(screen_pos)
	if not _is_in_bounds(tile_coord):
		return
	var path: Array = _pathfinder.compute_path(GameState.hero_tile, tile_coord)
	if path.size() < 2:
		_pending_path = []
		queue_redraw()
		return
	# First click: show preview. Second click on same tile: commit.
	if not _pending_path.is_empty() and (_pending_path.back() as Vector2i) == tile_coord:
		_commit_movement(path)
	else:
		_pending_path = path
		var cost: int = _pathfinder.path_cost(path)
		status_label.text = (
			"Path: %d tiles, %d MP needed (%d available). Click again to move."
			% [path.size() - 1, cost, GameState.hero_movement_left]
		)
		queue_redraw()


func _commit_movement(path: Array) -> void:
	if path.size() < 2:
		return
	# Truncate the path to whatever the hero can afford this turn.
	var affordable: Array = [path[0]]
	var spent: int = 0
	for i in range(1, path.size()):
		var prev: Vector2i = path[i - 1]
		var cur: Vector2i = path[i]
		var is_diag: bool = (prev.x != cur.x) and (prev.y != cur.y)
		var step_cost: float = float((_grid[cur.y][cur.x] as Tile).base_move_cost())
		if is_diag:
			step_cost *= 1.4142
		var step_int: int = int(round(step_cost))
		if spent + step_int > GameState.hero_movement_left:
			break
		spent += step_int
		affordable.append(cur)
	if affordable.size() < 2:
		status_label.text = "Not enough movement to step into that tile."
		_pending_path = []
		queue_redraw()
		return
	_pending_path = affordable
	_move_index = 1
	_is_moving = true
	_move_target_pixel = _tile_to_pixel(affordable[_move_index])
	queue_redraw()


func _advance_hero_movement(delta: float) -> void:
	var direction: Vector2 = _move_target_pixel - _hero_pixel_pos
	var distance: float = direction.length()
	var step: float = HERO_SPEED_PX_PER_SEC * delta
	if step >= distance:
		_hero_pixel_pos = _move_target_pixel
		var arrived: Vector2i = _pending_path[_move_index]
		_apply_step_cost(GameState.hero_tile, arrived)
		GameState.hero_tile = arrived
		_handle_arrival(arrived)
		if _is_moving:
			_move_index += 1
			if _move_index >= _pending_path.size():
				_finish_movement()
			else:
				_move_target_pixel = _tile_to_pixel(_pending_path[_move_index])
	else:
		_hero_pixel_pos += direction.normalized() * step
	queue_redraw()


func _apply_step_cost(from: Vector2i, to: Vector2i) -> void:
	var is_diag: bool = (from.x != to.x) and (from.y != to.y)
	var base: int = (_grid[to.y][to.x] as Tile).base_move_cost()
	var cost: int = int(round(float(base) * (1.4142 if is_diag else 1.0)))
	GameState.set_hero_position(to, cost)


func _handle_arrival(tile_coord: Vector2i) -> void:
	var t: Tile = _grid[tile_coord.y][tile_coord.x]
	if t.has_pickup():
		_collect_resource(tile_coord, t)
	elif t.has_monster():
		_start_battle(tile_coord, t)
	elif t.is_goal():
		status_label.text = "You found the treasure flag — campaign complete!"
		_is_moving = false
		_pending_path = []


func _collect_resource(_tile_coord: Vector2i, t: Tile) -> void:
	match t.object_kind:
		Tile.ObjectKind.RESOURCE_GOLD:
			GameState.add_resource("gold", t.resource_amount)
			status_label.text = "Picked up %d gold." % t.resource_amount
		Tile.ObjectKind.RESOURCE_WOOD:
			GameState.add_resource("wood", t.resource_amount)
			status_label.text = "Picked up %d wood." % t.resource_amount
		Tile.ObjectKind.RESOURCE_ORE:
			GameState.add_resource("ore", t.resource_amount)
			status_label.text = "Picked up %d ore." % t.resource_amount
		_:
			pass
	t.object_kind = Tile.ObjectKind.NONE
	t.resource_amount = 0
	_pathfinder.refresh()


func _start_battle(tile_coord: Vector2i, t: Tile) -> void:
	_is_moving = false
	_pending_path = []
	# Bring the hero to the tile immediately adjacent — H3 attacks land on
	# the monster's tile but the hero stays where they were. For the MVP we
	# rewind one step so the post-battle code can place the hero on the
	# defeated monster's tile.
	var prev: Vector2i = (
		_pending_path[_move_index - 1] if _pending_path.size() > 0 else GameState.hero_tile
	)
	GameState.hero_tile = prev
	_battle_target_tile = tile_coord
	GameState.last_battle_result = {
		"target_tile": tile_coord,
		"enemy_label": t.monster_label,
		"enemy_army": t.monster_army.duplicate(true),
	}
	# Hand-off: store the enemy army where Battlefield can read it.
	BattleSetup.target_tile = tile_coord
	BattleSetup.enemy_army = t.monster_army.duplicate(true)
	BattleSetup.enemy_label = t.monster_label
	BattleSetup.player_army = GameState.player_army.duplicate(true)
	SceneRouter.go_battlefield()


func _finish_movement() -> void:
	_is_moving = false
	_pending_path = []
	queue_redraw()


func _on_end_turn() -> void:
	GameState.advance_turn()
	status_label.text = "Day %d begins. Movement restored." % GameState.current_day


func _on_menu_pressed() -> void:
	SceneRouter.go_main_menu()


func _is_in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.y < _grid.size() and p.x < (_grid[0] as Array).size()


func _tile_to_pixel(t: Vector2i) -> Vector2:
	return (
		MAP_OFFSET + Vector2(t.x * TILE_SIZE + TILE_SIZE / 2.0, t.y * TILE_SIZE + TILE_SIZE / 2.0)
	)


func _pixel_to_tile(p: Vector2) -> Vector2i:
	var local: Vector2 = p - MAP_OFFSET
	return Vector2i(int(floor(local.x / TILE_SIZE)), int(floor(local.y / TILE_SIZE)))


func _refresh_resources_label(_res: Dictionary) -> void:
	resources_label.text = (
		"Gold: %d  |  Wood: %d  |  Ore: %d"
		% [
			GameState.resources.get("gold", 0),
			GameState.resources.get("wood", 0),
			GameState.resources.get("ore", 0),
		]
	)


func _refresh_mp_label(_pos: Vector2i, mp_left: int) -> void:
	mp_label.text = "Movement: %d / %d" % [mp_left, GameState.hero_movement_max]


func _refresh_day_label(day: int) -> void:
	day_label.text = "Day %d" % day


func _draw() -> void:
	var height: int = _grid.size()
	if height == 0:
		return
	var width: int = (_grid[0] as Array).size()
	for y in range(height):
		for x in range(width):
			var tile: Tile = _grid[y][x]
			var origin: Vector2 = MAP_OFFSET + Vector2(x * TILE_SIZE, y * TILE_SIZE)
			var rect: Rect2 = Rect2(origin, Vector2(TILE_SIZE, TILE_SIZE))
			var tex: Texture2D = AssetLoader.get_terrain_tile(tile.terrain_name())
			draw_texture_rect(tex, rect, false)
			_draw_tile_object(tile, origin)
	# Path preview.
	if not _pending_path.is_empty():
		for i in range(1, _pending_path.size()):
			var p_a: Vector2 = _tile_to_pixel(_pending_path[i - 1])
			var p_b: Vector2 = _tile_to_pixel(_pending_path[i])
			draw_line(p_a, p_b, Color(1.0, 0.95, 0.2, 0.85), 3.0)
		var dst: Vector2 = _tile_to_pixel(_pending_path[_pending_path.size() - 1])
		draw_circle(dst, 10.0, Color(1.0, 0.95, 0.2, 0.6))
	# Hero last so they sit on top.
	draw_circle(_hero_pixel_pos, 22.0, Color(0.10, 0.30, 0.85, 1.0))
	draw_circle(_hero_pixel_pos, 22.0 - 3.0, Color(0.45, 0.65, 1.0, 1.0))
	draw_string(
		ThemeDB.fallback_font,
		_hero_pixel_pos + Vector2(-8, 6),
		"H",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		18,
		Color.WHITE
	)


func _draw_tile_object(tile: Tile, origin: Vector2) -> void:
	var center: Vector2 = origin + Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	match tile.object_kind:
		Tile.ObjectKind.RESOURCE_GOLD:
			draw_circle(center, 14.0, Color(1.0, 0.85, 0.10))
			draw_string(
				ThemeDB.fallback_font,
				center + Vector2(-5, 5),
				"$",
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				18,
				Color(0.4, 0.3, 0.0)
			)
		Tile.ObjectKind.RESOURCE_WOOD:
			draw_rect(Rect2(center - Vector2(14, 6), Vector2(28, 12)), Color(0.45, 0.27, 0.10))
		Tile.ObjectKind.RESOURCE_ORE:
			draw_circle(center, 12.0, Color(0.55, 0.55, 0.60))
			draw_circle(center + Vector2(6, -3), 6.0, Color(0.70, 0.70, 0.75))
		Tile.ObjectKind.MONSTER:
			draw_circle(center, 18.0, Color(0.75, 0.10, 0.10))
			draw_string(
				ThemeDB.fallback_font,
				center + Vector2(-7, 6),
				"!",
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				22,
				Color.WHITE
			)
			draw_string(
				ThemeDB.fallback_font,
				origin + Vector2(2, TILE_SIZE - 4),
				tile.monster_label,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				12,
				Color.WHITE
			)
		Tile.ObjectKind.GOAL_FLAG:
			draw_rect(Rect2(center - Vector2(2, 18), Vector2(4, 36)), Color(0.4, 0.25, 0.10))
			draw_polygon(
				PackedVector2Array(
					[
						center + Vector2(2, -18),
						center + Vector2(22, -10),
						center + Vector2(2, -2),
					]
				),
				PackedColorArray(
					[Color(1.0, 0.85, 0.20), Color(1.0, 0.85, 0.20), Color(1.0, 0.85, 0.20)]
				)
			)
		_:
			pass

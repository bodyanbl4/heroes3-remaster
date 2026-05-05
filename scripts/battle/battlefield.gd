extends Node2D
## Hex-grid battle scene. Pulls inputs from `BattleSetup`, places the player
## stacks on the left edge and enemy stacks on the right edge, and runs a
## simple speed-based turn order with move / attack / wait / defend.
##
## Enemy AI is intentionally minimal: each enemy unit picks the nearest
## player unit, walks toward it, and attacks if adjacent (or shoots if it
## has shots and a target is reachable).

const HexGrid := preload("res://scripts/battle/hex_grid.gd")
const BattleUnit := preload("res://scripts/battle/battle_unit.gd")
const BattleDamage := preload("res://scripts/battle/damage.gd")

const HEX_SIZE: float = 36.0
const BATTLEFIELD_ORIGIN: Vector2 = Vector2(120, 140)

@onready var hud: CanvasLayer = $HUD
@onready var turn_label: Label = $HUD/Top/TurnLabel
@onready var unit_label: Label = $HUD/Top/UnitLabel
@onready var enemy_label: Label = $HUD/Top/EnemyLabel
@onready var status_label: Label = $HUD/Bottom/StatusLabel
@onready var wait_button: Button = $HUD/Bottom/WaitButton
@onready var defend_button: Button = $HUD/Bottom/DefendButton
@onready var flee_button: Button = $HUD/Bottom/FleeButton
@onready var battle_log: RichTextLabel = $HUD/Bottom/BattleLog

var hex: HexGrid
var units: Array = []
var current_unit_index: int = 0
var round_number: int = 1
var rng: RandomNumberGenerator
var awaiting_player_input: bool = false
var hovered_hex: Vector2i = Vector2i(-1, -1)
var battle_resolved: bool = false


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	hex = HexGrid.new(HEX_SIZE, BATTLEFIELD_ORIGIN)
	enemy_label.text = "Enemy: %s" % BattleSetup.enemy_label
	wait_button.pressed.connect(_on_wait_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	flee_button.pressed.connect(_on_flee_pressed)
	_spawn_units()
	_log("Battle starts: %s vs %s" % [GameState.hero_name, BattleSetup.enemy_label])
	_advance_to_next_unit()
	queue_redraw()


func _spawn_units() -> void:
	var player_col: int = 0
	var enemy_col: int = HexGrid.COLS - 1
	var center_row: int = HexGrid.ROWS / 2
	var rows_player: Array = _evenly_spaced_rows(BattleSetup.player_army.size(), center_row)
	var rows_enemy: Array = _evenly_spaced_rows(BattleSetup.enemy_army.size(), center_row)
	for i in range(BattleSetup.player_army.size()):
		var stack: Dictionary = BattleSetup.player_army[i]
		var coord: Vector2i = Vector2i(player_col, rows_player[i])
		var u: BattleUnit = BattleUnit.from_stack(stack, BattleUnit.Side.PLAYER, coord)
		units.append(u)
	for i in range(BattleSetup.enemy_army.size()):
		var stack2: Dictionary = BattleSetup.enemy_army[i]
		var coord2: Vector2i = Vector2i(enemy_col, rows_enemy[i])
		var u2: BattleUnit = BattleUnit.from_stack(stack2, BattleUnit.Side.ENEMY, coord2)
		units.append(u2)


func _evenly_spaced_rows(num_units: int, center_row: int) -> Array:
	if num_units <= 0:
		return []
	var rows: Array = []
	var spacing: int = max(1, int(HexGrid.ROWS / max(1, num_units + 1)))
	for i in range(num_units):
		var r: int = clamp(
			center_row - (num_units - 1) * spacing / 2 + i * spacing, 0, HexGrid.ROWS - 1
		)
		rows.append(r)
	return rows


## Re-orders the round: living units sorted by speed desc, then by side
## (player first on tie). Units that have already acted are skipped.
func _build_turn_order() -> Array:
	var living: Array = []
	for u in units:
		if u.is_alive() and not u.has_acted_this_round:
			living.append(u)
	living.sort_custom(
		func(a: BattleUnit, b: BattleUnit) -> bool:
			if a.has_waited != b.has_waited:
				# Waited units act *after* non-waited ones, in reverse speed.
				return not a.has_waited
			if a.has_waited and b.has_waited:
				return a.speed < b.speed
			if a.speed != b.speed:
				return a.speed > b.speed
			return a.side < b.side
	)
	return living


func _advance_to_next_unit() -> void:
	if battle_resolved:
		return
	if _check_battle_end():
		return
	var order: Array = _build_turn_order()
	if order.is_empty():
		round_number += 1
		_log("--- Round %d ---" % round_number)
		for u in units:
			(u as BattleUnit).reset_for_new_round()
		order = _build_turn_order()
		if order.is_empty():
			return
	var active: BattleUnit = order[0]
	turn_label.text = (
		"Round %d  |  Active: %s [%s]"
		% [
			round_number,
			active.name,
			"Player" if active.side == BattleUnit.Side.PLAYER else "Enemy"
		]
	)
	if active.side == BattleUnit.Side.PLAYER:
		awaiting_player_input = true
		unit_label.text = (
			"%s ×%d (HP %d/%d) — click an enemy to attack or a hex to move"
			% [active.name, active.count, active.top_hp, active.max_hp]
		)
		_set_player_buttons_enabled(true)
	else:
		awaiting_player_input = false
		unit_label.text = "Enemy %s ×%d is acting..." % [active.name, active.count]
		_set_player_buttons_enabled(false)
		_run_enemy_ai(active)
	queue_redraw()


func _set_player_buttons_enabled(enabled: bool) -> void:
	wait_button.disabled = not enabled
	defend_button.disabled = not enabled
	flee_button.disabled = not enabled


func _input(event: InputEvent) -> void:
	if not awaiting_player_input or battle_resolved:
		return
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		hovered_hex = hex.pixel_to_hex(mm.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_handle_player_click(mb.position)


func _handle_player_click(pos: Vector2) -> void:
	var coord: Vector2i = hex.pixel_to_hex(pos)
	if not hex.is_in_bounds(coord):
		return
	var active: BattleUnit = _build_turn_order()[0]
	var clicked_unit: BattleUnit = _unit_at(coord)
	if clicked_unit != null and clicked_unit.side != active.side:
		_attempt_attack(active, clicked_unit)
	elif clicked_unit == null:
		_attempt_move(active, coord)


func _attempt_move(active: BattleUnit, target: Vector2i) -> void:
	var dist: int = hex.distance(active.coord, target)
	if dist > active.speed:
		_status(
			"%s can't reach that hex (speed %d, distance %d)." % [active.name, active.speed, dist]
		)
		return
	if _unit_at(target) != null:
		_status("Hex is occupied.")
		return
	active.coord = target
	active.has_acted_this_round = true
	_log("%s moves to %d,%d." % [active.name, target.x, target.y])
	queue_redraw()
	_advance_to_next_unit()


func _attempt_attack(active: BattleUnit, target: BattleUnit) -> void:
	if active.ranged and active.shots > 0:
		_resolve_attack(active, target, true)
		return
	# Melee: attacker must be adjacent. If not, walk toward target first.
	var dist: int = hex.distance(active.coord, target.coord)
	if dist > 1:
		var step: Vector2i = _step_toward(active.coord, target.coord, active.speed)
		if step == active.coord:
			_status("Cannot reach the target.")
			return
		active.coord = step
		_log("%s closes in to %d,%d." % [active.name, step.x, step.y])
		var new_dist: int = hex.distance(active.coord, target.coord)
		if new_dist > 1:
			active.has_acted_this_round = true
			queue_redraw()
			_advance_to_next_unit()
			return
	_resolve_attack(active, target, false)


func _resolve_attack(attacker: BattleUnit, defender: BattleUnit, is_ranged: bool) -> void:
	var damage: int = BattleDamage.compute_damage(attacker, defender, rng)
	var killed: int = defender.take_damage(damage)
	if is_ranged:
		attacker.shots = max(0, attacker.shots - 1)
	var verb: String = "shoots" if is_ranged else "attacks"
	if killed > 0:
		_log(
			(
				"%s %s %s for %d damage, killing %d."
				% [attacker.name, verb, defender.name, damage, killed]
			)
		)
	else:
		_log("%s %s %s for %d damage." % [attacker.name, verb, defender.name, damage])
	# Retaliation (melee only, defender must be alive and not yet retaliated this round).
	if not is_ranged and defender.is_alive():
		var counter: int = BattleDamage.compute_damage(defender, attacker, rng)
		var counter_killed: int = attacker.take_damage(counter)
		if counter_killed > 0:
			_log("%s retaliates for %d, killing %d." % [defender.name, counter, counter_killed])
		else:
			_log("%s retaliates for %d." % [defender.name, counter])
	attacker.has_acted_this_round = true
	queue_redraw()
	_advance_to_next_unit()


func _step_toward(from: Vector2i, to: Vector2i, max_steps: int) -> Vector2i:
	# Greedy single-step pathfinding: each step pick the neighbour with the
	# smallest hex distance to the target. Sufficient because the grid is
	# small and obstacles are only other units.
	var current: Vector2i = from
	for _i in range(max_steps):
		var best: Vector2i = current
		var best_dist: int = hex.distance(current, to)
		for n in hex.neighbors(current):
			if _unit_at(n) != null and n != to:
				continue
			var d: int = hex.distance(n, to)
			if d < best_dist:
				best_dist = d
				best = n
		if best == current:
			break
		if hex.distance(best, to) <= 1:
			# Don't actually step *onto* the target; stop adjacent.
			current = best
			break
		current = best
	return current


func _unit_at(coord: Vector2i) -> BattleUnit:
	for u in units:
		if (u as BattleUnit).is_alive() and (u as BattleUnit).coord == coord:
			return u
	return null


func _run_enemy_ai(unit: BattleUnit) -> void:
	# Pick the nearest living player unit.
	var target: BattleUnit = null
	var best_dist: int = 1000
	for u in units:
		if (u as BattleUnit).side == BattleUnit.Side.PLAYER and (u as BattleUnit).is_alive():
			var d: int = hex.distance(unit.coord, (u as BattleUnit).coord)
			if d < best_dist:
				best_dist = d
				target = u
	if target == null:
		unit.has_acted_this_round = true
		await get_tree().create_timer(0.2).timeout
		_advance_to_next_unit()
		return
	await get_tree().create_timer(0.4).timeout
	if unit.ranged and unit.shots > 0:
		_resolve_attack(unit, target, true)
		return
	if best_dist <= 1:
		_resolve_attack(unit, target, false)
		return
	var step: Vector2i = _step_toward(unit.coord, target.coord, unit.speed)
	if step != unit.coord and _unit_at(step) == null:
		unit.coord = step
		_log("%s advances to %d,%d." % [unit.name, step.x, step.y])
	if hex.distance(unit.coord, target.coord) <= 1:
		_resolve_attack(unit, target, false)
		return
	unit.has_acted_this_round = true
	queue_redraw()
	_advance_to_next_unit()


func _on_wait_pressed() -> void:
	if not awaiting_player_input:
		return
	var active: BattleUnit = _build_turn_order()[0]
	active.has_waited = true
	_log("%s waits." % active.name)
	_advance_to_next_unit()


func _on_defend_pressed() -> void:
	if not awaiting_player_input:
		return
	var active: BattleUnit = _build_turn_order()[0]
	active.is_defending = true
	active.has_acted_this_round = true
	_log("%s defends." % active.name)
	_advance_to_next_unit()


func _on_flee_pressed() -> void:
	if battle_resolved:
		return
	battle_resolved = true
	_log("You flee from battle!")
	GameState.last_battle_result = {
		"outcome": "flee",
		"target_tile": BattleSetup.target_tile,
		"remaining_army": _serialize_player_survivors(),
	}
	_status("Returning to adventure map...")
	await get_tree().create_timer(1.2).timeout
	SceneRouter.go_adventure_map()


func _check_battle_end() -> bool:
	var any_player_alive: bool = false
	var any_enemy_alive: bool = false
	for u in units:
		if not (u as BattleUnit).is_alive():
			continue
		if (u as BattleUnit).side == BattleUnit.Side.PLAYER:
			any_player_alive = true
		else:
			any_enemy_alive = true
	if any_player_alive and any_enemy_alive:
		return false
	battle_resolved = true
	if any_player_alive:
		_log("Victory!")
		GameState.last_battle_result = {
			"outcome": "victory",
			"target_tile": BattleSetup.target_tile,
			"remaining_army": _serialize_player_survivors(),
		}
		_status("Victory! Returning to adventure map...")
	else:
		_log("Defeat — your army was wiped out.")
		GameState.last_battle_result = {
			"outcome": "defeat",
			"target_tile": BattleSetup.target_tile,
			"remaining_army": [],
		}
		_status("Defeat! Returning to adventure map...")
	awaiting_player_input = false
	_set_player_buttons_enabled(false)
	queue_redraw()
	_return_after_delay()
	return true


func _return_after_delay() -> void:
	await get_tree().create_timer(1.6).timeout
	SceneRouter.go_adventure_map()


func _serialize_player_survivors() -> Array:
	var out: Array = []
	for u in units:
		if (u as BattleUnit).side == BattleUnit.Side.PLAYER and (u as BattleUnit).is_alive():
			out.append((u as BattleUnit).to_stack())
	return out


func _log(msg: String) -> void:
	battle_log.append_text("[color=#cccccc]%s[/color]\n" % msg)


func _status(msg: String) -> void:
	status_label.text = msg


func _draw() -> void:
	# Field background.
	var bg_rect: Rect2 = Rect2(60, 110, 1160, 480)
	draw_rect(bg_rect, Color(0.36, 0.55, 0.24))
	# Hex tiles.
	for r in range(HexGrid.ROWS):
		for c in range(HexGrid.COLS):
			var coord: Vector2i = Vector2i(c, r)
			var corners: PackedVector2Array = hex.hex_corners(coord)
			var fill: Color = Color(0.30, 0.45, 0.20)
			if coord == hovered_hex:
				fill = Color(0.80, 0.75, 0.20)
			var colors: PackedColorArray = PackedColorArray()
			for _i in range(corners.size()):
				colors.append(fill)
			draw_polygon(corners, colors)
			# Outline.
			var outline_corners: PackedVector2Array = corners.duplicate()
			outline_corners.append(corners[0])
			draw_polyline(outline_corners, Color(0.18, 0.28, 0.12), 1.0)
	# Units.
	for u in units:
		if not (u as BattleUnit).is_alive():
			continue
		var unit: BattleUnit = u as BattleUnit
		var center: Vector2 = hex.hex_to_pixel(unit.coord)
		var ring: Color = (
			Color(0.10, 0.30, 0.85)
			if unit.side == BattleUnit.Side.PLAYER
			else Color(0.85, 0.15, 0.15)
		)
		draw_circle(center, HEX_SIZE * 0.7, ring)
		draw_circle(center, HEX_SIZE * 0.55, unit.color)
		var label: String = "%s\n×%d" % [unit.name, unit.count]
		draw_string_outline(
			ThemeDB.fallback_font,
			center + Vector2(-HEX_SIZE * 0.7, -HEX_SIZE * 0.1),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			HEX_SIZE * 1.4,
			12,
			2,
			Color.BLACK
		)
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-HEX_SIZE * 0.7, -HEX_SIZE * 0.1),
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			HEX_SIZE * 1.4,
			12,
			Color.WHITE
		)
		if unit.is_defending:
			draw_arc(center, HEX_SIZE * 0.85, 0.0, TAU, 24, Color(0.85, 0.85, 0.30), 2.0)

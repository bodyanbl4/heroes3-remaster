class_name BattleUnit
extends RefCounted
## In-combat representation of a creature stack. Combines a creature template
## (from CreaturesDB) with mutable state: count alive, HP of the top
## creature in the stack, position on the battlefield, and turn-state
## flags (waited, defended, acted).

enum Side { PLAYER, ENEMY }

var creature_id: String
var name: String
var side: int = Side.PLAYER
var coord: Vector2i
var initial_count: int
var count: int
var top_hp: int
var max_hp: int
var attack: int
var defense: int
var speed: int
var min_damage: int
var max_damage: int
var ranged: bool = false
var shots: int = 0
var has_acted_this_round: bool = false
var has_waited: bool = false
var is_defending: bool = false
var color: Color = Color.GRAY


static func from_stack(stack: Dictionary, side_value: int, coord_value: Vector2i) -> BattleUnit:
	var data: Dictionary = CreaturesDB.get_creature(String(stack.get("creature_id", "pikeman")))
	var unit: BattleUnit = BattleUnit.new()
	unit.creature_id = String(stack.get("creature_id", "pikeman"))
	unit.name = String(data.get("name", unit.creature_id))
	unit.side = side_value
	unit.coord = coord_value
	unit.initial_count = int(stack.get("count", 1))
	unit.count = unit.initial_count
	unit.max_hp = int(data.get("hp", 1))
	unit.top_hp = unit.max_hp
	unit.attack = int(data.get("attack", 1))
	unit.defense = int(data.get("defense", 1))
	unit.speed = int(data.get("speed", 1))
	unit.min_damage = int(data.get("min_damage", 1))
	unit.max_damage = int(data.get("max_damage", 1))
	unit.ranged = bool(data.get("ranged", false))
	unit.shots = int(data.get("shots", 0))
	unit.color = data.get("color", Color.GRAY)
	return unit


func is_alive() -> bool:
	return count > 0


func to_stack() -> Dictionary:
	return {
		"creature_id": creature_id,
		"count": count,
	}


## Apply incoming damage. Returns the number of creatures killed in this
## stack so callers can produce a battle log line.
func take_damage(total_damage: int) -> int:
	if total_damage <= 0:
		return 0
	var killed: int = 0
	var remaining: int = total_damage
	# First absorb damage from the top creature's remaining HP.
	if remaining < top_hp:
		top_hp -= remaining
		return 0
	remaining -= top_hp
	count -= 1
	killed += 1
	top_hp = max_hp
	if count <= 0:
		count = 0
		return killed
	while remaining >= max_hp and count > 0:
		remaining -= max_hp
		count -= 1
		killed += 1
	if count <= 0:
		count = 0
		return killed
	if remaining > 0:
		top_hp = max_hp - remaining
	return killed


func reset_for_new_round() -> void:
	has_acted_this_round = false
	has_waited = false
	is_defending = false

extends Node
## Holds the persistent state of the current game session: the player's hero,
## their owned army, resources, and a reference to the active map.
##
## This is an autoload (singleton) so any scene can read or mutate the state
## via `GameState.<...>`. Combat and adventure-map scenes both read from here.

signal resources_changed(resources: Dictionary)
signal hero_moved(new_tile: Vector2i, mp_left: int)
signal turn_advanced(day: int)

const STARTING_GOLD: int = 2500
const STARTING_WOOD: int = 10
const STARTING_ORE: int = 10
const STARTING_MP: int = 1500

var current_day: int = 1
var hero_tile: Vector2i = Vector2i(2, 2)
var hero_movement_left: int = STARTING_MP
var hero_movement_max: int = STARTING_MP
var hero_name: String = "Sir Catherine"

## Resource counts. Keys: "gold", "wood", "ore", "mercury", "sulfur",
## "crystal", "gems".
var resources: Dictionary = {
	"gold": STARTING_GOLD,
	"wood": STARTING_WOOD,
	"ore": STARTING_ORE,
	"mercury": 0,
	"sulfur": 0,
	"crystal": 0,
	"gems": 0,
}

## Player army: an array of {creature_id: String, count: int} dictionaries.
## Up to 7 stacks, matching the original game.
var player_army: Array[Dictionary] = []

## Result of the most recent battle, written by Battlefield and read by
## AdventureMap to remove the defeated monster stack.
## Shape: { "outcome": "victory"|"defeat"|"flee", "target_tile": Vector2i,
## "remaining_army": Array }
var last_battle_result: Dictionary = {}


func _ready() -> void:
	reset_for_new_game()


func reset_for_new_game() -> void:
	current_day = 1
	hero_tile = Vector2i(2, 2)
	hero_movement_left = STARTING_MP
	hero_movement_max = STARTING_MP
	resources = {
		"gold": STARTING_GOLD,
		"wood": STARTING_WOOD,
		"ore": STARTING_ORE,
		"mercury": 0,
		"sulfur": 0,
		"crystal": 0,
		"gems": 0,
	}
	player_army = [
		{"creature_id": "pikeman", "count": 20},
		{"creature_id": "archer", "count": 10},
		{"creature_id": "swordsman", "count": 5},
	]
	last_battle_result = {}
	resources_changed.emit(resources)


func add_resource(kind: String, amount: int) -> void:
	if not resources.has(kind):
		push_warning("Unknown resource kind: %s" % kind)
		return
	resources[kind] += amount
	resources_changed.emit(resources)


func spend_resource(kind: String, amount: int) -> bool:
	if not resources.has(kind):
		return false
	if resources[kind] < amount:
		return false
	resources[kind] -= amount
	resources_changed.emit(resources)
	return true


func set_hero_position(tile: Vector2i, mp_cost: int) -> void:
	hero_tile = tile
	hero_movement_left = max(0, hero_movement_left - mp_cost)
	hero_moved.emit(hero_tile, hero_movement_left)


func advance_turn() -> void:
	current_day += 1
	hero_movement_left = hero_movement_max
	# Income: gold per day. Real H3 income comes from towns; this is a
	# placeholder until towns are implemented.
	resources["gold"] += 500
	resources_changed.emit(resources)
	hero_moved.emit(hero_tile, hero_movement_left)
	turn_advanced.emit(current_day)


func total_army_count() -> int:
	var total: int = 0
	for stack in player_army:
		total += int(stack.get("count", 0))
	return total

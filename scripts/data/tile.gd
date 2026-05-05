class_name Tile
extends RefCounted
## Pure-data description of a single adventure-map cell.
##
## Held inside `AdventureMap.grid` in row-major order. Mutable: objects on
## the tile (resources, monsters) are removed when picked up or defeated.

enum Terrain { GRASS, DIRT, SAND, WATER, ROCK, TREE }

enum ObjectKind {
	NONE,
	RESOURCE_GOLD,
	RESOURCE_WOOD,
	RESOURCE_ORE,
	MONSTER,
	GOAL_FLAG,
}

var terrain: Terrain = Terrain.GRASS
var object_kind: ObjectKind = ObjectKind.NONE
## For RESOURCE_* kinds: the amount granted on pickup.
var resource_amount: int = 0
## For MONSTER kind: the army to fight (array of stack dicts).
var monster_army: Array[Dictionary] = []
## For MONSTER kind: a label shown on the map.
var monster_label: String = ""


func is_passable() -> bool:
	if terrain == Terrain.WATER or terrain == Terrain.ROCK or terrain == Terrain.TREE:
		return false
	return true


func is_traversable_for_pathfinding() -> bool:
	# Monsters and goal flags block the path *destination only* — i.e., they
	# are entered, not crossed. Pathfinding treats them as passable to allow
	# routing into the tile but the AdventureMap clamps the path so it ends
	# on the object tile.
	return is_passable()


func has_pickup() -> bool:
	match object_kind:
		ObjectKind.RESOURCE_GOLD, ObjectKind.RESOURCE_WOOD, ObjectKind.RESOURCE_ORE:
			return true
		_:
			return false


func has_monster() -> bool:
	return object_kind == ObjectKind.MONSTER


func is_goal() -> bool:
	return object_kind == ObjectKind.GOAL_FLAG


func terrain_name() -> StringName:
	match terrain:
		Terrain.GRASS:
			return &"grass"
		Terrain.DIRT:
			return &"dirt"
		Terrain.SAND:
			return &"sand"
		Terrain.WATER:
			return &"water"
		Terrain.ROCK:
			return &"rock"
		Terrain.TREE:
			return &"tree"
		_:
			return &"grass"


## Movement cost in MP to enter this tile from a 4-directionally adjacent
## tile. Diagonal cost is computed by the pathfinder.
func base_move_cost() -> int:
	if not is_passable():
		return 999_999
	# Real H3 has terrain-specific costs (sand is slower than road). For
	# the prototype, all passable terrain costs the same.
	return 100

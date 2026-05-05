class_name MapGenerator
extends RefCounted
## Builds a deterministic small test map for the MVP. Replaces what will
## eventually become an `.h3m` parser in `AssetLoader`.

const Tile := preload("res://scripts/data/tile.gd")

const MAP_WIDTH: int = 30
const MAP_HEIGHT: int = 20


static func generate(seed_value: int = 12345) -> Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var grid: Array = []
	grid.resize(MAP_HEIGHT)
	for y in range(MAP_HEIGHT):
		var row: Array = []
		row.resize(MAP_WIDTH)
		for x in range(MAP_WIDTH):
			row[x] = _build_tile(x, y, rng)
		grid[y] = row
	_carve_paths(grid)
	_place_resources(grid, rng)
	_place_monsters(grid, rng)
	_place_goal(grid)
	return grid


static func _build_tile(x: int, y: int, rng: RandomNumberGenerator) -> Tile:
	var tile: Tile = Tile.new()
	# Border ring of rocks to bound the playable area.
	if x == 0 or y == 0 or x == MAP_WIDTH - 1 or y == MAP_HEIGHT - 1:
		tile.terrain = Tile.Terrain.ROCK
		return tile
	var roll: float = rng.randf()
	if roll < 0.06:
		tile.terrain = Tile.Terrain.TREE
	elif roll < 0.10:
		tile.terrain = Tile.Terrain.ROCK
	elif roll < 0.18:
		tile.terrain = Tile.Terrain.DIRT
	elif roll < 0.20:
		tile.terrain = Tile.Terrain.SAND
	else:
		tile.terrain = Tile.Terrain.GRASS
	return tile


## Carve a guaranteed grass corridor between the player start (2,2) and the
## goal flag near the far corner so the map is always solvable.
static func _carve_paths(grid: Array) -> void:
	var start: Vector2i = Vector2i(2, 2)
	var goal: Vector2i = Vector2i(MAP_WIDTH - 3, MAP_HEIGHT - 3)
	var cur: Vector2i = start
	while cur != goal:
		var t: Tile = grid[cur.y][cur.x]
		t.terrain = Tile.Terrain.GRASS
		t.object_kind = Tile.ObjectKind.NONE
		if cur.x < goal.x:
			cur.x += 1
		elif cur.x > goal.x:
			cur.x -= 1
		elif cur.y < goal.y:
			cur.y += 1
		elif cur.y > goal.y:
			cur.y -= 1
	var goal_tile: Tile = grid[goal.y][goal.x]
	goal_tile.terrain = Tile.Terrain.GRASS
	goal_tile.object_kind = Tile.ObjectKind.NONE


static func _place_resources(grid: Array, rng: RandomNumberGenerator) -> void:
	var placed: int = 0
	var attempts: int = 0
	while placed < 8 and attempts < 200:
		attempts += 1
		var x: int = rng.randi_range(3, MAP_WIDTH - 3)
		var y: int = rng.randi_range(3, MAP_HEIGHT - 3)
		var tile: Tile = grid[y][x]
		if tile.terrain != Tile.Terrain.GRASS or tile.object_kind != Tile.ObjectKind.NONE:
			continue
		var roll: int = rng.randi_range(0, 2)
		match roll:
			0:
				tile.object_kind = Tile.ObjectKind.RESOURCE_GOLD
				tile.resource_amount = rng.randi_range(500, 1500)
			1:
				tile.object_kind = Tile.ObjectKind.RESOURCE_WOOD
				tile.resource_amount = rng.randi_range(3, 7)
			_:
				tile.object_kind = Tile.ObjectKind.RESOURCE_ORE
				tile.resource_amount = rng.randi_range(3, 7)
		placed += 1


static func _place_monsters(grid: Array, rng: RandomNumberGenerator) -> void:
	var monster_specs: Array = [
		{"label": "Wolves", "army": [{"creature_id": "wolf", "count": 6}]},
		{"label": "Orcs", "army": [{"creature_id": "orc", "count": 4}]},
		{"label": "Gremlins", "army": [{"creature_id": "gremlin", "count": 12}]},
		{"label": "Gargoyles", "army": [{"creature_id": "gargoyle", "count": 4}]},
	]
	var placed: int = 0
	var attempts: int = 0
	while placed < monster_specs.size() and attempts < 200:
		attempts += 1
		var x: int = rng.randi_range(5, MAP_WIDTH - 4)
		var y: int = rng.randi_range(3, MAP_HEIGHT - 3)
		var tile: Tile = grid[y][x]
		if tile.terrain != Tile.Terrain.GRASS or tile.object_kind != Tile.ObjectKind.NONE:
			continue
		# Don't place a monster right next to the start.
		if Vector2i(x, y).distance_squared_to(Vector2i(2, 2)) < 16:
			continue
		var spec: Dictionary = monster_specs[placed]
		tile.object_kind = Tile.ObjectKind.MONSTER
		tile.monster_label = String(spec["label"])
		var raw: Array = spec["army"] as Array
		var typed: Array[Dictionary] = []
		for entry in raw:
			typed.append((entry as Dictionary).duplicate(true))
		tile.monster_army = typed
		placed += 1


static func _place_goal(grid: Array) -> void:
	var goal: Vector2i = Vector2i(MAP_WIDTH - 3, MAP_HEIGHT - 3)
	var t: Tile = grid[goal.y][goal.x]
	t.terrain = Tile.Terrain.GRASS
	t.object_kind = Tile.ObjectKind.GOAL_FLAG

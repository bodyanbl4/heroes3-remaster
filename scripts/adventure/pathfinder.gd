class_name AdventurePathfinder
extends RefCounted
## Wraps Godot's `AStarGrid2D` with the rules used by the adventure map:
## passability based on `Tile.is_passable`, diagonal moves allowed, and
## destination tiles with monsters/pickups treated as enterable.

const Tile := preload("res://scripts/data/tile.gd")

var _astar: AStarGrid2D
var _grid: Array
var _width: int
var _height: int


func _init(grid: Array) -> void:
	_grid = grid
	_height = grid.size()
	_width = (grid[0] as Array).size() if _height > 0 else 0
	_astar = AStarGrid2D.new()
	_astar.region = Rect2i(0, 0, _width, _height)
	_astar.cell_size = Vector2(1, 1)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_AT_LEAST_ONE_WALKABLE
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_astar.update()
	_refresh_solid_cells()


func _refresh_solid_cells() -> void:
	for y in range(_height):
		for x in range(_width):
			var tile: Tile = _grid[y][x]
			_astar.set_point_solid(Vector2i(x, y), not tile.is_passable())


## Recompute walkability after the map mutates (monster defeated, pickup
## taken). Cheap because AStarGrid2D doesn't re-allocate on edits.
func refresh() -> void:
	_refresh_solid_cells()


## Returns an Array[Vector2i] including both endpoints, or an empty array if
## no path exists. Pickup and monster tiles are valid destinations even
## though some are technically passable: the map carves a clear ring of
## terrain around them.
func compute_path(from: Vector2i, to: Vector2i) -> Array:
	if not _is_in_bounds(from) or not _is_in_bounds(to):
		return []
	if from == to:
		return [from]
	var dest_tile: Tile = _grid[to.y][to.x]
	# Temporarily mark the destination walkable so the A* search can finish
	# even if a monster sits on it.
	var was_solid: bool = _astar.is_point_solid(to)
	if dest_tile.has_monster() or dest_tile.is_goal() or dest_tile.has_pickup():
		_astar.set_point_solid(to, false)
	var path: PackedVector2Array = _astar.get_id_path(from, to)
	if was_solid:
		_astar.set_point_solid(to, true)
	var out: Array = []
	for v in path:
		out.append(Vector2i(v))
	return out


## Movement cost (in adventure-map MP) to traverse a path returned by
## `compute_path`. The cost of the source tile is not counted; each
## subsequent tile costs its `base_move_cost`, scaled by sqrt(2) for
## diagonal moves.
func path_cost(path: Array) -> int:
	if path.size() < 2:
		return 0
	var total: float = 0.0
	for i in range(1, path.size()):
		var prev: Vector2i = path[i - 1]
		var cur: Vector2i = path[i]
		var tile: Tile = _grid[cur.y][cur.x]
		var is_diag: bool = (prev.x != cur.x) and (prev.y != cur.y)
		var step: float = float(tile.base_move_cost())
		if is_diag:
			step *= 1.4142
		total += step
	return int(round(total))


func _is_in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.y >= 0 and p.x < _width and p.y < _height

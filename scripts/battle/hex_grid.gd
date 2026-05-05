class_name HexGrid
extends RefCounted
## Pointy-top hex grid layout used by the battlefield. Even rows are shifted
## right by half a hex width to mimic the offset layout of the original
## Heroes 3 battle screen (15 columns, 11 rows).
##
## All coordinates are stored as Vector2i (col, row).

const COLS: int = 15
const ROWS: int = 11

var hex_size: float
var origin: Vector2


func _init(hex_size_value: float, origin_value: Vector2) -> void:
	hex_size = hex_size_value
	origin = origin_value


func hex_to_pixel(coord: Vector2i) -> Vector2:
	var col_step: float = hex_size * sqrt(3.0)
	var row_step: float = hex_size * 1.5
	var x: float = origin.x + col_step * (float(coord.x) + (0.5 if coord.y % 2 == 1 else 0.0))
	var y: float = origin.y + row_step * float(coord.y)
	return Vector2(x, y)


func pixel_to_hex(p: Vector2) -> Vector2i:
	# Approximate inverse: compute the floating axial coords, snap to the
	# closest hex centre.
	var best: Vector2i = Vector2i.ZERO
	var best_dist: float = INF
	for r in range(ROWS):
		for c in range(COLS):
			var center: Vector2 = hex_to_pixel(Vector2i(c, r))
			var d: float = center.distance_to(p)
			if d < best_dist:
				best_dist = d
				best = Vector2i(c, r)
	return best


func is_in_bounds(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < COLS and coord.y >= 0 and coord.y < ROWS


## All six neighbour offsets depend on the row's parity (even / odd).
func neighbors(coord: Vector2i) -> Array:
	var even_offsets: Array = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(-1, 1),
		Vector2i(0, 1),
	]
	var odd_offsets: Array = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(0, 1),
		Vector2i(1, 1),
	]
	var offsets: Array = odd_offsets if coord.y % 2 == 1 else even_offsets
	var out: Array = []
	for off in offsets:
		var n: Vector2i = coord + off
		if is_in_bounds(n):
			out.append(n)
	return out


## Hex distance using offset coords: convert to cube and take the chebyshev-
## like measure used in classic hex grids.
func distance(a: Vector2i, b: Vector2i) -> int:
	var ax: int = a.x - int((a.y - (a.y & 1)) / 2)
	var az: int = a.y
	var ay: int = -ax - az
	var bx: int = b.x - int((b.y - (b.y & 1)) / 2)
	var bz: int = b.y
	var by: int = -bx - bz
	return int((abs(ax - bx) + abs(ay - by) + abs(az - bz)) / 2)


func hex_corners(coord: Vector2i) -> PackedVector2Array:
	var center: Vector2 = hex_to_pixel(coord)
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var angle: float = deg_to_rad(60.0 * float(i) - 30.0)
		pts.append(center + Vector2(cos(angle), sin(angle)) * hex_size)
	return pts

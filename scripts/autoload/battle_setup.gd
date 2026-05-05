extends Node
## Hand-off bag from AdventureMap to Battlefield. Holds the armies and the
## tile coordinate the player attacked, separated from `GameState` so that
## restoring after defeat doesn't bring battle inputs along with it.

var target_tile: Vector2i = Vector2i(-1, -1)
var enemy_army: Array[Dictionary] = []
var enemy_label: String = ""
var player_army: Array[Dictionary] = []

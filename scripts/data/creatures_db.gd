extends Node
## Static-style lookup of creature stats. Implemented as an autoload so any
## scene can call `CreaturesDB.get_creature("pikeman")`.
##
## Stats use the original Heroes of Might and Magic III scale (level 1
## creatures have ~2-5 HP, ~1-3 damage, etc.) but values are tuned for the
## prototype and will be replaced once the real data tables (CRTRAITS.TXT)
## are parsed from the user's H3 install.

const FACTION_CASTLE: StringName = &"castle"
const FACTION_RAMPART: StringName = &"rampart"
const FACTION_NEUTRAL: StringName = &"neutral"


static func get_all() -> Dictionary:
	return _DATA


static func get_creature(creature_id: String) -> Dictionary:
	if not _DATA.has(creature_id):
		push_warning("Unknown creature id: %s" % creature_id)
		return _DATA["pikeman"]
	return (_DATA[creature_id] as Dictionary).duplicate(true)


# Indexed by id. Each entry: name, faction, attack, defense, hp, speed,
# min_damage, max_damage, ranged (bool), shots (int, ranged only), tier.
const _DATA: Dictionary = {
	"pikeman":
	{
		"name": "Pikeman",
		"faction": FACTION_CASTLE,
		"attack": 4,
		"defense": 5,
		"hp": 10,
		"speed": 4,
		"min_damage": 1,
		"max_damage": 3,
		"ranged": false,
		"shots": 0,
		"tier": 1,
		"color": Color(0.78, 0.78, 0.86),
	},
	"archer":
	{
		"name": "Archer",
		"faction": FACTION_CASTLE,
		"attack": 6,
		"defense": 3,
		"hp": 10,
		"speed": 4,
		"min_damage": 2,
		"max_damage": 3,
		"ranged": true,
		"shots": 12,
		"tier": 2,
		"color": Color(0.85, 0.65, 0.30),
	},
	"swordsman":
	{
		"name": "Swordsman",
		"faction": FACTION_CASTLE,
		"attack": 10,
		"defense": 12,
		"hp": 35,
		"speed": 5,
		"min_damage": 6,
		"max_damage": 9,
		"ranged": false,
		"shots": 0,
		"tier": 4,
		"color": Color(0.80, 0.80, 0.95),
	},
	"gremlin":
	{
		"name": "Gremlin",
		"faction": &"tower",
		"attack": 3,
		"defense": 3,
		"hp": 4,
		"speed": 4,
		"min_damage": 1,
		"max_damage": 2,
		"ranged": false,
		"shots": 0,
		"tier": 1,
		"color": Color(0.55, 0.45, 0.30),
	},
	"gargoyle":
	{
		"name": "Gargoyle",
		"faction": &"tower",
		"attack": 6,
		"defense": 6,
		"hp": 16,
		"speed": 6,
		"min_damage": 2,
		"max_damage": 3,
		"ranged": false,
		"shots": 0,
		"tier": 2,
		"color": Color(0.60, 0.55, 0.50),
	},
	"wolf":
	{
		"name": "Wolf",
		"faction": FACTION_NEUTRAL,
		"attack": 6,
		"defense": 2,
		"hp": 10,
		"speed": 6,
		"min_damage": 2,
		"max_damage": 4,
		"ranged": false,
		"shots": 0,
		"tier": 2,
		"color": Color(0.45, 0.40, 0.35),
	},
	"orc":
	{
		"name": "Orc",
		"faction": FACTION_NEUTRAL,
		"attack": 5,
		"defense": 4,
		"hp": 15,
		"speed": 4,
		"min_damage": 2,
		"max_damage": 5,
		"ranged": true,
		"shots": 8,
		"tier": 3,
		"color": Color(0.50, 0.55, 0.30),
	},
}

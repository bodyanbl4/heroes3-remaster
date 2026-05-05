class_name BattleDamage
extends RefCounted
## Pure damage-formula helpers, kept separate from BattleUnit so the rules
## can be unit-tested without instantiating units.
##
## Approximation of the original H3 damage formula:
##   base = roll(min_damage..max_damage) * count
##   if attack > defense: damage *= 1 + 0.05 * (attack - defense), capped at 4x
##   if defense > attack: damage *= 1 - 0.025 * (defense - attack), floored at 0.3
##   defending halves the receiver's modifier (we model it by +50% defense)


static func compute_damage(
	attacker: BattleUnit,
	defender: BattleUnit,
	rng: RandomNumberGenerator,
) -> int:
	if not attacker.is_alive() or not defender.is_alive():
		return 0
	var per_creature: int = rng.randi_range(attacker.min_damage, attacker.max_damage)
	var base: int = per_creature * max(attacker.count, 1)
	var effective_defense: int = defender.defense
	if defender.is_defending:
		effective_defense += int(round(float(defender.defense) * 0.5))
	var modifier: float = 1.0
	if attacker.attack > effective_defense:
		modifier += 0.05 * float(attacker.attack - effective_defense)
		modifier = min(modifier, 4.0)
	elif effective_defense > attacker.attack:
		modifier -= 0.025 * float(effective_defense - attacker.attack)
		modifier = max(modifier, 0.3)
	var damage: int = int(round(float(base) * modifier))
	return max(damage, 1)

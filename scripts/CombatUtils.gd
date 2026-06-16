class_name CombatUtils

static var DAMAGE_TABLE: Dictionary = {
	Constants.DamageType.NORMAL: {
		Constants.ArmorType.UNARMORED: 1.0,
		Constants.ArmorType.LIGHT:     1.5,
		Constants.ArmorType.MEDIUM:    2.0,
		Constants.ArmorType.HEAVY:     0.7,
	},
	Constants.DamageType.PIERCING: {
		Constants.ArmorType.UNARMORED: 2.0,
		Constants.ArmorType.LIGHT:     1.5,
		Constants.ArmorType.MEDIUM:    0.5,
		Constants.ArmorType.HEAVY:     0.35,
	},
	Constants.DamageType.MAGIC: {
		Constants.ArmorType.UNARMORED: 1.0,
		Constants.ArmorType.LIGHT:     1.0,
		Constants.ArmorType.MEDIUM:    1.25,
		Constants.ArmorType.HEAVY:     0.35,
	},
	Constants.DamageType.SIEGE: {
		Constants.ArmorType.UNARMORED: 0.5,
		Constants.ArmorType.LIGHT:     0.5,
		Constants.ArmorType.MEDIUM:    0.5,
		Constants.ArmorType.HEAVY:     2.0,
	},
	Constants.DamageType.CHAOS: {
		Constants.ArmorType.UNARMORED: 1.0,
		Constants.ArmorType.LIGHT:     1.0,
		Constants.ArmorType.MEDIUM:    1.0,
		Constants.ArmorType.HEAVY:     1.0,
	},
}


static func calculate_damage(base: float, dtype: int, atype: int, target_hp_ratio: float = 1.0) -> float:
	var multiplier: float = DAMAGE_TABLE[dtype][atype]
	var damage := base * multiplier * GameState.tower_damage_multiplier

	match dtype:
		Constants.DamageType.MAGIC:
			damage *= GameState.fire_damage_bonus
		Constants.DamageType.SIEGE:
			# Heavy×3 bonus only applies to enemies above 50% HP
			if target_hp_ratio > 0.5:
				damage *= GameState.siege_vs_high_hp_bonus
		Constants.DamageType.CHAOS:
			if GameState.chaos_extra_armor_ignore > 0.0:
				damage += base * GameState.tower_damage_multiplier * GameState.chaos_extra_armor_ignore

	return damage


static func get_damage_color(dtype: int) -> Color:
	match dtype:
		Constants.DamageType.NORMAL:   return Color.WHITE
		Constants.DamageType.PIERCING: return Color.YELLOW
		Constants.DamageType.MAGIC:    return Color.RED
		Constants.DamageType.SIEGE:    return Color.GRAY
		Constants.DamageType.CHAOS:    return Color.PURPLE
	return Color.WHITE


static func calculate_wave_hp_scale(wave: int) -> float:
	return pow(Constants.ENEMY_HP_SCALE, wave - 1)


static func calculate_wave_dmg_scale(wave: int) -> float:
	return pow(Constants.ENEMY_DMG_SCALE, wave - 1)

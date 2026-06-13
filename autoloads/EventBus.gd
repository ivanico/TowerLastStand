extends Node

# Combat
signal enemy_died(enemy: Node, position: Vector2)
signal enemy_reached_tower(enemy: Node)
signal tower_damaged(amount: float)
signal tower_healed(amount: float)
signal tower_died

# XP & leveling
signal xp_gained(amount: int)
signal level_up(new_level: int)

# Wave & phase
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal phase_changed(new_phase: int)
signal boss_spawned
signal boss_died

# Draft
signal draft_opened
signal draft_closed
signal card_selected(card_data: Resource)

# Synergy
signal synergy_threshold_reached(tag: int, level: int)

# Meta
signal run_ended(victory: bool, wave_reached: int)
signal materials_earned(chapter_mat: int, universal_mat: int)
signal tower_upgraded(tower_id: int, new_star: int)
signal spell_ranked_up(spell_id: String, new_rank: int)

class_name SaveData
extends Resource

@export var owned_towers: Array[int]
@export var tower_stars: Dictionary
@export var spell_ranks: Dictionary
@export var discovered_spells: Array[String]
@export var materials: Dictionary          # { MaterialType: int }
@export var energy: int
@export var energy_last_regen_time: int    # Unix timestamp (seconds)
@export var premium_currency: int
@export var selected_tower_id: int
@export var chapters_completed: Array[int]
@export var best_wave_per_chapter: Dictionary

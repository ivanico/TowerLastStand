class_name TowerData
extends Resource

@export var tower_id: int             # Constants.TowerID
@export var tower_name: String
@export var description: String
@export var icon: Texture2D
@export var tower_scene: PackedScene

# Base stats (Star 1)
@export var base_hp: int
@export var base_damage: float
@export var base_fire_rate: float     # seconds between shots
@export var base_range: float
@export var base_armor: int
@export var base_attack_type: int     # Constants.DamageType

# Star bonuses (index 0 = Star 2, index 4 = Star 5)
@export var star_hp_bonus: Array[int]
@export var star_damage_bonus: Array[float]

# Passive descriptions (for UI display)
@export var passive_description: String
@export var passive_star3_description: String
@export var passive_star5_description: String

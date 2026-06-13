class_name StatUpgradeData
extends Resource

@export var upgrade_id: String
@export var upgrade_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: int          # Constants.CardRarity
@export var tags: Array[int]     # Constants.SynergyTag values

# Stat deltas applied to GameState on pick
@export var hp_bonus: int = 0
@export var regen_bonus: float = 0.0
@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var range_bonus: float = 0.0
@export var armor_bonus: int = 0
@export var xp_multiplier: float = 1.0
@export var is_stackable: bool = false
@export var stack_max: int = 1

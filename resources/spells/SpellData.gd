class_name SpellData
extends Resource

@export var spell_id: String
@export var spell_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: int               # Constants.CardRarity
@export var spell_category: int       # Constants.SpellCategory
@export var damage_type: int          # Constants.DamageType
@export var tags: Array[int]          # Constants.SynergyTag values
@export var damage: float
@export var cooldown: float
@export var range: float
@export var aoe_radius: float = 0.0
@export var pierce_count: int = 0
@export var chain_count: int = 0
@export var projectile_scene: PackedScene
@export var is_stackable: bool = false
@export var stack_max: int = 1

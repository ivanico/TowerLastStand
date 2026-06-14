class_name WaveConfig
extends Resource

@export var wave_number: int
@export var burst_count: int
@export var trickle_count: int
@export var trickle_interval: float
@export var enemy_pool: Array[int]  # Constants.EnemyType values
@export var is_boss_wave: bool = false

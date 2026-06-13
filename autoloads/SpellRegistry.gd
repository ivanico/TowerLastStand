extends Node

var all_spells: Array
var all_stat_upgrades: Array


func _ready() -> void:
	pass  # Populated in Epic 03 when .tres resource files are created


func get_all_cards() -> Array:
	return all_spells + all_stat_upgrades

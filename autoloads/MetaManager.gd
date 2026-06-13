extends Node

var owned_towers: Array[int]
var tower_stars: Dictionary       # { TowerID: int }
var spell_ranks: Dictionary       # { spell_id: String: int }
var discovered_spells: Array[String]
var materials: Dictionary         # { MaterialType: int }
var energy: int
var premium_currency: int
var selected_tower_id: int


func _ready() -> void:
	energy            = Constants.MAX_ENERGY
	selected_tower_id = Constants.TowerID.IRONCLAD
	owned_towers      = [Constants.TowerID.IRONCLAD]
	tower_stars       = {}
	spell_ranks       = {}
	discovered_spells = []
	materials         = {}
	premium_currency  = 0


func save() -> void:
	print("MetaManager: save called")


func load() -> void:
	print("MetaManager: load called")


func spend_energy() -> bool:
	if energy > 0:
		energy -= 1
		return true
	return false


func restore_energy(amount: int) -> void:
	energy = min(energy + amount, Constants.MAX_ENERGY)

extends Node

signal energy_changed(new_energy: int, max_energy: int)

var owned_towers: Array[int]
var tower_stars: Dictionary         # { TowerID: int }
var spell_ranks: Dictionary         # { spell_id: int }
var discovered_spells: Array[String]
var materials: Dictionary           # { MaterialType: int }
var energy: int
var premium_currency: int
var selected_tower_id: int
var chapters_completed: Array[int]
var best_wave_per_chapter: Dictionary

const ENERGY_REGEN_INTERVAL: int = 3600  # 1 hour in seconds

var _energy_regen_timer: Timer


func _ready() -> void:
	_energy_regen_timer = Timer.new()
	_energy_regen_timer.wait_time  = float(ENERGY_REGEN_INTERVAL)
	_energy_regen_timer.autostart  = true
	_energy_regen_timer.one_shot   = false
	_energy_regen_timer.timeout.connect(_on_energy_regen_tick)
	add_child(_energy_regen_timer)
	load_data()
	_apply_offline_energy_regen()
	if not FileAccess.file_exists(SaveManager.SAVE_PATH):
		save()


func save() -> void:
	var data                      := SaveData.new()
	data.owned_towers             = owned_towers.duplicate()
	data.tower_stars              = tower_stars.duplicate()
	data.spell_ranks              = spell_ranks.duplicate()
	data.discovered_spells        = discovered_spells.duplicate()
	data.materials                = materials.duplicate()
	data.energy                   = energy
	data.energy_last_regen_time   = int(Time.get_unix_time_from_system())
	data.premium_currency         = premium_currency
	data.selected_tower_id        = selected_tower_id
	data.chapters_completed       = chapters_completed.duplicate()
	data.best_wave_per_chapter    = best_wave_per_chapter.duplicate()
	SaveManager.save(data)


func load_data() -> void:
	var data: SaveData = SaveManager.load()
	owned_towers          = data.owned_towers.duplicate()
	tower_stars           = data.tower_stars.duplicate()
	spell_ranks           = data.spell_ranks.duplicate()
	discovered_spells     = data.discovered_spells.duplicate()
	materials             = data.materials.duplicate()
	energy                = data.energy
	premium_currency      = data.premium_currency
	selected_tower_id     = data.selected_tower_id
	chapters_completed    = data.chapters_completed.duplicate()
	best_wave_per_chapter = data.best_wave_per_chapter.duplicate()
	print("[MetaManager] Data loaded — energy=%d/%d, chapter_mats=%d, universal_mats=%d, discovered_spells=%d, tower_stars=%s" % [
		energy, Constants.MAX_ENERGY,
		materials.get(Constants.MaterialType.CHAPTER_MAT, 0),
		materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0),
		discovered_spells.size(),
		str(tower_stars)
	])


func _apply_offline_energy_regen() -> void:
	if energy >= Constants.MAX_ENERGY:
		return
	var data: SaveData = SaveManager.load()
	var now     := int(Time.get_unix_time_from_system())
	var elapsed := now - data.energy_last_regen_time
	if elapsed <= 0:
		return
	var ticks := elapsed / ENERGY_REGEN_INTERVAL
	if ticks > 0:
		print("[MetaManager] Offline regen — elapsed=%ds, ticks=%d, energy %d→%d" % [
			elapsed, ticks, energy, mini(energy + ticks, Constants.MAX_ENERGY)
		])
		restore_energy(ticks)


func _on_energy_regen_tick() -> void:
	if energy < Constants.MAX_ENERGY:
		restore_energy(1)
		energy_changed.emit(energy, Constants.MAX_ENERGY)


func spend_energy() -> bool:
	if energy > 0:
		energy -= 1
		save()
		energy_changed.emit(energy, Constants.MAX_ENERGY)
		return true
	return false


func restore_energy(amount: int) -> void:
	energy = mini(energy + amount, Constants.MAX_ENERGY)
	save()
	energy_changed.emit(energy, Constants.MAX_ENERGY)


func get_tower_star(tower_id: int) -> int:
	return tower_stars.get(tower_id, 1)


func upgrade_tower_star(tower_id: int) -> bool:
	var current_star := get_tower_star(tower_id)
	if current_star >= Constants.TOWER_MAX_STARS:
		return false
	var cost := get_tower_upgrade_cost(tower_id, current_star + 1)
	var chapter_cost  : int = cost.get(Constants.MaterialType.CHAPTER_MAT, 0)
	var universal_cost: int = cost.get(Constants.MaterialType.UNIVERSAL_MAT, 0)
	if materials.get(Constants.MaterialType.CHAPTER_MAT, 0) < chapter_cost:
		return false
	if materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0) < universal_cost:
		return false
	materials[Constants.MaterialType.CHAPTER_MAT]   -= chapter_cost
	materials[Constants.MaterialType.UNIVERSAL_MAT] -= universal_cost
	tower_stars[tower_id] = current_star + 1
	save()
	EventBus.tower_upgraded.emit(tower_id, tower_stars[tower_id])
	return true


func get_tower_upgrade_cost(tower_id: int, to_star: int) -> Dictionary:
	# Filled in Task 05-03 — returns zero cost for now
	match to_star:
		2: return { Constants.MaterialType.CHAPTER_MAT: 10,  Constants.MaterialType.UNIVERSAL_MAT: 0 }
		3: return { Constants.MaterialType.CHAPTER_MAT: 25,  Constants.MaterialType.UNIVERSAL_MAT: 1 }
		4: return { Constants.MaterialType.CHAPTER_MAT: 50,  Constants.MaterialType.UNIVERSAL_MAT: 3 }
		5: return { Constants.MaterialType.CHAPTER_MAT: 100, Constants.MaterialType.UNIVERSAL_MAT: 5 }
	return { Constants.MaterialType.CHAPTER_MAT: 0, Constants.MaterialType.UNIVERSAL_MAT: 0 }


func get_spell_rank(spell_id: String) -> int:
	return spell_ranks.get(spell_id, 1)


func upgrade_spell_rank(spell_id: String) -> bool:
	if spell_id not in discovered_spells:
		return false
	var current_rank := get_spell_rank(spell_id)
	if current_rank >= Constants.SPELL_MAX_RANK:
		return false
	var cost := get_spell_rank_cost(spell_id, current_rank + 1)
	var chapter_cost  : int = cost.get(Constants.MaterialType.CHAPTER_MAT, 0)
	var universal_cost: int = cost.get(Constants.MaterialType.UNIVERSAL_MAT, 0)
	if materials.get(Constants.MaterialType.CHAPTER_MAT, 0) < chapter_cost:
		return false
	if materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0) < universal_cost:
		return false
	materials[Constants.MaterialType.CHAPTER_MAT]   -= chapter_cost
	materials[Constants.MaterialType.UNIVERSAL_MAT] -= universal_cost
	spell_ranks[spell_id] = current_rank + 1
	save()
	EventBus.spell_ranked_up.emit(spell_id, spell_ranks[spell_id])
	return true


func get_spell_rank_cost(spell_id: String, to_rank: int) -> Dictionary:
	# Filled in Task 05-03 — returns zero cost for now
	match to_rank:
		2: return { Constants.MaterialType.CHAPTER_MAT: 8,  Constants.MaterialType.UNIVERSAL_MAT: 0 }
		3: return { Constants.MaterialType.CHAPTER_MAT: 18, Constants.MaterialType.UNIVERSAL_MAT: 1 }
		4: return { Constants.MaterialType.CHAPTER_MAT: 35, Constants.MaterialType.UNIVERSAL_MAT: 2 }
		5: return { Constants.MaterialType.CHAPTER_MAT: 60, Constants.MaterialType.UNIVERSAL_MAT: 4 }
	return { Constants.MaterialType.CHAPTER_MAT: 0, Constants.MaterialType.UNIVERSAL_MAT: 0 }


func discover_spell(spell_id: String) -> void:
	if spell_id not in discovered_spells:
		discovered_spells.append(spell_id)
		save()
		print("[MetaManager] Spell discovered: %s (total discovered: %d)" % [spell_id, discovered_spells.size()])


func add_materials(type: int, amount: int) -> void:
	materials[type] = materials.get(type, 0) + amount
	save()

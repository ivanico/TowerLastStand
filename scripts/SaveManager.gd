class_name SaveManager

const SAVE_PATH := "user://save.tres"


static func save(data: SaveData) -> void:
	ResourceSaver.save(data, SAVE_PATH)


static func load() -> SaveData:
	if FileAccess.file_exists(SAVE_PATH):
		var data := ResourceLoader.load(SAVE_PATH) as SaveData
		if data != null:
			return data
		push_warning("[SaveManager] Save file found but failed to parse — creating default.")
	else:
		print("[SaveManager] No save file found — creating default save.")
	return _create_default_save()


static func delete() -> void:
	DirAccess.remove_absolute(SAVE_PATH)
	print("[SaveManager] Save file deleted.")


static func _create_default_save() -> SaveData:
	var data := SaveData.new()
	data.owned_towers             = [Constants.TowerID.IRONCLAD]
	data.tower_stars              = { Constants.TowerID.IRONCLAD: 1 }
	data.spell_ranks              = {}
	data.discovered_spells        = []
	data.materials                = {
		Constants.MaterialType.CHAPTER_MAT:   0,
		Constants.MaterialType.UNIVERSAL_MAT: 0,
	}
	data.energy                   = Constants.MAX_ENERGY
	data.energy_last_regen_time   = int(Time.get_unix_time_from_system())
	data.premium_currency         = 0
	data.selected_tower_id        = Constants.TowerID.IRONCLAD
	data.chapters_completed       = []
	data.best_wave_per_chapter    = {}
	print("[SaveManager] Default save created — energy=%d, tower=IRONCLAD★1" % data.energy)
	return data

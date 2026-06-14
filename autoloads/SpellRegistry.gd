extends Node

var all_spells: Array[SpellData]
var all_stat_upgrades: Array[StatUpgradeData]


func _ready() -> void:
	for res in _load_tres("res://resources/spells/"):
		if res is SpellData:
			all_spells.append(res)
	for res in _load_tres("res://resources/upgrades/"):
		if res is StatUpgradeData:
			all_stat_upgrades.append(res)



func get_spell(id: String) -> SpellData:
	for spell in all_spells:
		if spell.spell_id == id:
			return spell
	return null


func get_spells_by_tag(tag: int) -> Array[SpellData]:
	var result: Array[SpellData] = []
	for spell in all_spells:
		if spell.tags.has(tag):
			result.append(spell)
	return result


func get_all_cards() -> Array:
	return all_spells + all_stat_upgrades


func _load_tres(path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("SpellRegistry: cannot open %s" % path)
		return result
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".tres"):
			var res = load(path + f)
			if res != null:
				result.append(res)
		f = dir.get_next()
	dir.list_dir_end()
	return result

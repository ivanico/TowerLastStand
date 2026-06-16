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



func get_spell_for_run(spell_id: String) -> SpellData:
	var base := get_spell(spell_id)
	if base == null:
		return null
	var rank := MetaManager.get_spell_rank(spell_id)
	if rank <= 1:
		return base
	var s := base.duplicate() as SpellData
	if rank >= 2:
		s.damage   *= 1.15
		s.cooldown *= 0.95
	if rank >= 3:
		s.pierce_count += 1
	if rank >= 4:
		s.damage   *= 1.20
		s.cooldown *= 0.90
	if rank >= 5:
		s.pierce_count += 1
		s.chain_count  += 1
	return s


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

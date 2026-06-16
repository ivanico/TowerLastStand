extends Node

var _card_pool: Array
var _taken_cards: Array
var _current_draft_cards: Array[Resource]
var _draft_trigger: String = "wave_clear"


func reset_run() -> void:
	_card_pool             = []
	_taken_cards           = []
	_current_draft_cards   = []
	_draft_trigger         = "wave_clear"


func open_draft(trigger: String = "wave_clear") -> void:
	if GameState.phase == Constants.GamePhase.DRAFT:
		return
	_draft_trigger = trigger
	GameState.phase = Constants.GamePhase.DRAFT
	EventBus.phase_changed.emit(Constants.GamePhase.DRAFT)
	_current_draft_cards = get_draft_cards()
	var names: Array[String] = []
	for card in _current_draft_cards:
		if card is SpellData:
			names.append(card.spell_name)
		elif card is StatUpgradeData:
			names.append(card.upgrade_name)
	get_tree().paused = true
	EventBus.draft_opened.emit()


func get_draft_cards() -> Array[Resource]:
	var pool := SpellRegistry.get_all_cards()
	var filtered: Array[Resource] = []
	for card in pool:
		if not _is_excluded(card):
			filtered.append(card)
	var count := Constants.DRAFT_CARDS_SHOWN
	# [Utility]x5 synergy: show 4 cards
	if GameState.active_synergies.has(Constants.SynergyTag.UTILITY):
		if Constants.SYNERGY_THRESHOLD_HIGH in GameState.active_synergies[Constants.SynergyTag.UTILITY]:
			count = 4
	var drawn := _weighted_draw(filtered, count)
	# Tag guarantee: if player has 2+ distinct tags, ensure at least 1 drawn card shares a tag
	if GameState.tag_counts.size() >= 2:
		var has_match := false
		for card in drawn:
			for tag in card.tags:
				if GameState.tag_counts.has(tag):
					has_match = true
					break
			if has_match:
				break
		if not has_match:
			var active_tags := GameState.tag_counts.keys()
			var tagged: Array[Resource] = []
			for card in filtered:
				if card in drawn:
					continue
				for tag in card.tags:
					if tag in active_tags:
						tagged.append(card)
						break
			if not tagged.is_empty():
				drawn[drawn.size() - 1] = tagged[randi() % tagged.size()]
	for i in drawn.size():
		if drawn[i] is SpellData:
			drawn[i] = SpellRegistry.get_spell_for_run((drawn[i] as SpellData).spell_id)
	return drawn


func _weighted_draw(pool: Array, count: int) -> Array[Resource]:
	var result: Array[Resource] = []
	var remaining := pool.duplicate()
	var actual := mini(count, remaining.size())
	for i in actual:
		var total_weight: float = 0.0
		for card in remaining:
			total_weight += _card_weight(card)
		if total_weight <= 0.0:
			break
		var roll := randf() * total_weight
		var cumulative: float = 0.0
		var chosen: Resource = null
		for card in remaining:
			cumulative += _card_weight(card)
			if roll <= cumulative:
				chosen = card
				break
		if chosen == null:
			chosen = remaining[remaining.size() - 1]
		result.append(chosen)
		remaining.erase(chosen)
	return result


func _card_weight(card: Resource) -> float:
	match card.rarity:
		Constants.CardRarity.COMMON: return 60.0
		Constants.CardRarity.RARE:   return 30.0
		Constants.CardRarity.EPIC:   return 10.0
	return 60.0


func _is_excluded(card: Resource) -> bool:
	if card is SpellData:
		var count := 0
		for active in GameState.active_spells:
			if active.spell_id == card.spell_id:
				count += 1
		return count > 0 and (not card.is_stackable or count >= card.stack_max)
	elif card is StatUpgradeData:
		var count := 0
		for taken in _taken_cards:
			if taken is StatUpgradeData and taken.upgrade_id == card.upgrade_id:
				count += 1
		return count > 0 and (not card.is_stackable or count >= card.stack_max)
	return false


func select_card(card: Resource) -> void:
	var picked_name: String = card.spell_name if card is SpellData else card.upgrade_name
	GameState.apply_card(card)
	_taken_cards.append(card)
	GameState.phase = Constants.GamePhase.WAVE
	get_tree().paused = false
	EventBus.card_selected.emit(card)
	EventBus.draft_closed.emit()
	EventBus.phase_changed.emit(Constants.GamePhase.WAVE)
	if _draft_trigger == "wave_clear":
		WaveManager.start_wave(GameState.wave_number)

extends Node

# Signals
signal hp_changed(new_hp: int, max_hp: int)
signal xp_bar_updated(current: int, needed: int)
signal tag_count_changed(tag: int, new_count: int)

# Run state
var phase: int
var wave_number: int
var run_level: int
var run_xp: int
var run_xp_to_next: int

# Tower live stats
var tower_hp: int
var tower_max_hp: int
var tower_regen_per_sec: float
var tower_damage_multiplier: float
var tower_fire_rate_multiplier: float
var tower_range_bonus: float
var tower_armor: int

# Active spells this run (typed to Array[SpellData] once SpellData is defined in Epic 01-12)
var active_spells: Array

# Synergy tag counts
var tag_counts: Dictionary       # { SynergyTag: int }
var active_synergies: Dictionary # { SynergyTag: Array[int] }

# Run stats
var total_kills: int
var waves_cleared: int
var damage_dealt: float

# Scene reference — set by GameWorld._ready(), not cleared on reset
var tower_node: Node


func _ready() -> void:
	reset()
	EventBus.xp_gained.connect(gain_xp)


func start_run(tower_data) -> void:
	reset()
	if tower_data != null:
		tower_max_hp = tower_data.base_hp
		tower_armor  = tower_data.base_armor
	else:
		tower_max_hp = 1000
		tower_armor  = 0
	tower_hp = tower_max_hp
	phase = Constants.GamePhase.WAVE
	EventBus.phase_changed.emit(phase)
	hp_changed.emit(tower_hp, tower_max_hp)


func end_run(victory: bool) -> void:
	phase = Constants.GamePhase.VICTORY if victory else Constants.GamePhase.DEFEAT
	EventBus.run_ended.emit(victory, wave_number)


func gain_xp(amount: int) -> void:
	run_xp += amount
	xp_bar_updated.emit(run_xp, run_xp_to_next)
	if run_xp >= run_xp_to_next:
		run_xp -= run_xp_to_next
		run_level += 1
		run_xp_to_next = Constants.XP_PER_LEVEL_BASE * run_level
		EventBus.level_up.emit(run_level)
		DraftManager.open_draft("level_up")


func apply_card(card: Resource) -> void:
	if card is SpellData:
		if active_spells.size() < Constants.MAX_SPELL_SLOTS:
			active_spells.append(card)
			for tag in card.tags:
				add_tag(tag)
			if tower_node != null:
				tower_node.add_spell(card)
	elif card is StatUpgradeData:
		tower_max_hp += card.hp_bonus
		tower_hp = min(tower_hp + card.hp_bonus, tower_max_hp)
		tower_regen_per_sec += card.regen_bonus
		tower_damage_multiplier *= card.damage_multiplier
		tower_fire_rate_multiplier *= card.fire_rate_multiplier
		tower_range_bonus += card.range_bonus
		tower_armor += card.armor_bonus
		for tag in card.tags:
			add_tag(tag)
		hp_changed.emit(tower_hp, tower_max_hp)


func add_tag(tag: int) -> void:
	if not tag_counts.has(tag):
		tag_counts[tag] = 0
	tag_counts[tag] += 1
	tag_count_changed.emit(tag, tag_counts[tag])
	var count: int = tag_counts[tag]
	if count == Constants.SYNERGY_THRESHOLD_LOW or count == Constants.SYNERGY_THRESHOLD_HIGH:
		if not active_synergies.has(tag):
			active_synergies[tag] = []
		active_synergies[tag].append(count)
		EventBus.synergy_threshold_reached.emit(tag, count)


func take_damage(amount: float) -> void:
	tower_hp = max(0, tower_hp - int(amount))
	hp_changed.emit(tower_hp, tower_max_hp)
	if tower_hp == 0:
		EventBus.tower_died.emit()


func heal(amount: float) -> void:
	tower_hp = min(tower_max_hp, tower_hp + int(amount))
	hp_changed.emit(tower_hp, tower_max_hp)
	EventBus.tower_healed.emit(amount)


func reset() -> void:
	phase                    = Constants.GamePhase.WAVE
	wave_number              = 1
	run_level                = 1
	run_xp                   = 0
	run_xp_to_next           = Constants.XP_PER_LEVEL_BASE
	tower_hp                 = 0
	tower_max_hp             = 0
	tower_regen_per_sec      = 0.0
	tower_damage_multiplier  = 1.0
	tower_fire_rate_multiplier = 1.0
	tower_range_bonus        = 0.0
	tower_armor              = 0
	active_spells            = []
	tag_counts               = {}
	active_synergies         = {}
	total_kills              = 0
	waves_cleared            = 0
	damage_dealt             = 0.0

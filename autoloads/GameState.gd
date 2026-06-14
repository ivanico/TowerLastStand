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

# Synergy flags — reset each run
var fire_damage_bonus: float        = 1.0
var fire_leaves_burn_patch: bool    = false
var global_chain_bonus: int         = 0
var chain_applies_debuff: bool      = false
var global_pierce_bonus: int        = 0
var pierce_heals_on_kill: bool      = false
var siege_vs_high_hp_bonus: float   = 1.0
var siege_stuns: bool               = false
var damage_reduction: float         = 0.0
var armor_regen_active: bool        = false
var bonus_projectile_every_n: int   = 0
var materials_bonus_multiplier: float = 1.0
var bonus_cache_on_perfect_run: bool  = false
var chaos_extra_armor_ignore: float = 0.0
var chaos_insta_kill_chance: float  = 0.0

var _armor_regen_timer: Timer


func _ready() -> void:
	_armor_regen_timer = Timer.new()
	_armor_regen_timer.wait_time = 5.0
	_armor_regen_timer.one_shot  = false
	_armor_regen_timer.timeout.connect(_on_armor_regen_tick)
	add_child(_armor_regen_timer)
	reset()
	EventBus.xp_gained.connect(gain_xp)
	EventBus.enemy_died.connect(func(_e: Node, _p: Vector2) -> void: total_kills += 1)
	EventBus.wave_cleared.connect(func(_w: int) -> void: waves_cleared += 1)


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
		xp_bar_updated.emit(run_xp, run_xp_to_next)


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
		_apply_synergy_bonus(tag, count)


func take_damage(amount: float) -> void:
	var effective := amount * (1.0 - damage_reduction)
	tower_hp = max(0, tower_hp - int(effective))
	hp_changed.emit(tower_hp, tower_max_hp)
	EventBus.tower_damaged.emit(amount)
	if tower_hp == 0:
		EventBus.tower_died.emit()


func heal(amount: float) -> void:
	tower_hp = min(tower_max_hp, tower_hp + int(amount))
	hp_changed.emit(tower_hp, tower_max_hp)
	EventBus.tower_healed.emit(amount)


func _apply_synergy_bonus(tag: int, level: int) -> void:
	match tag:
		Constants.SynergyTag.FIRE:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				fire_damage_bonus = 1.25
			else:
				fire_leaves_burn_patch = true
		Constants.SynergyTag.CHAIN:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				global_chain_bonus += 1
			else:
				chain_applies_debuff = true
		Constants.SynergyTag.PIERCING:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				global_pierce_bonus += 1
			else:
				pierce_heals_on_kill = true
		Constants.SynergyTag.HEAVY:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				siege_vs_high_hp_bonus = 1.4
			else:
				siege_stuns = true
		Constants.SynergyTag.ARMOR:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				damage_reduction = 0.15
			else:
				armor_regen_active = true
				_armor_regen_timer.start()
		Constants.SynergyTag.OFFENSE:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				tower_damage_multiplier *= 1.10
			else:
				bonus_projectile_every_n = 10
		Constants.SynergyTag.UTILITY:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				tower_fire_rate_multiplier *= 0.90
		Constants.SynergyTag.GOLD:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				materials_bonus_multiplier = 1.30
			else:
				bonus_cache_on_perfect_run = true
		Constants.SynergyTag.CHAOS_TAG:
			if level == Constants.SYNERGY_THRESHOLD_LOW:
				chaos_extra_armor_ignore = 0.50
			else:
				chaos_insta_kill_chance = 0.15


func _on_armor_regen_tick() -> void:
	if armor_regen_active and tower_max_hp > 0:
		heal(tower_max_hp * 0.01)


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
	fire_damage_bonus        = 1.0
	fire_leaves_burn_patch   = false
	global_chain_bonus       = 0
	chain_applies_debuff     = false
	global_pierce_bonus      = 0
	pierce_heals_on_kill     = false
	siege_vs_high_hp_bonus   = 1.0
	siege_stuns              = false
	damage_reduction         = 0.0
	armor_regen_active       = false
	bonus_projectile_every_n = 0
	materials_bonus_multiplier  = 1.0
	bonus_cache_on_perfect_run  = false
	chaos_extra_armor_ignore = 0.0
	chaos_insta_kill_chance  = 0.0
	if _armor_regen_timer:
		_armor_regen_timer.stop()

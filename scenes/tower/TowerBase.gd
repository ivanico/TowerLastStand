extends Area2D

const _PROJECTILE_SCENE      := preload("res://scenes/spells/ProjectileBase.tscn")
const _AOE_ZONE_SCENE        := preload("res://scenes/spells/AoEZone.tscn")
const _PERSISTENT_ZONE_SCENE := preload("res://scenes/spells/PersistentZone.tscn")
const _LAND_MINE_SCENE       := preload("res://scenes/spells/LandMine.tscn")

var base_range: float
var active_spells: Array
var _spell_cooldowns: Dictionary
var _enemies_in_range: Array
var _projectile_container: Node
var _zone_container: Node
var _mine_container: Node
var _reflect_percent: float = 0.0


func _ready() -> void:
	add_to_group("tower")
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLUE)
	$Sprite2D.texture = ImageTexture.create_from_image(img)

	$RegenTimer.timeout.connect(_on_regen_timer_timeout)
	$AttackRangeArea.body_entered.connect(_on_attack_range_body_entered)
	$AttackRangeArea.body_exited.connect(_on_attack_range_body_exited)
	EventBus.enemy_died.connect(func(enemy: Node, _pos: Vector2) -> void:
		_enemies_in_range.erase(enemy))
	base_range = ($AttackRangeArea.get_node("CollisionShape2D").shape as CircleShape2D).radius
	EventBus.card_selected.connect(_on_card_selected)


func _physics_process(delta: float) -> void:
	for spell in active_spells:
		_spell_cooldowns[spell.spell_id] -= delta
		if _spell_cooldowns[spell.spell_id] <= 0.0:
			_spell_cooldowns[spell.spell_id] = spell.cooldown * GameState.tower_fire_rate_multiplier
			_fire_spell(spell)


func take_damage(amount: float) -> void:
	GameState.take_damage(amount)


func add_spell(spell: Resource) -> void:
	if spell.spell_category == Constants.SpellCategory.PASSIVE:
		_apply_passive_effect(spell)
		return
	active_spells.append(spell)
	_spell_cooldowns[spell.spell_id] = 0.0


func _apply_passive_effect(spell: SpellData) -> void:
	if spell.spell_id == "mana_shield":
		_reflect_percent = 0.10
		if not EventBus.tower_damaged.is_connected(_on_tower_damaged):
			EventBus.tower_damaged.connect(_on_tower_damaged)
		print("[TowerBase] Passive applied: Mana Shield (10% reflect)")


func _on_tower_damaged(amount: float) -> void:
	if _reflect_percent <= 0.0:
		return
	var reflect_dmg := amount * _reflect_percent
	var attacker := _get_target(base_range + 100.0, Constants.TargetMode.CLOSEST)
	if attacker != null:
		attacker.take_damage(reflect_dmg, Constants.DamageType.MAGIC)


func _on_card_selected(_card: Resource) -> void:
	var effective_range := base_range + GameState.tower_range_bonus
	($AttackRangeArea.get_node("CollisionShape2D").shape as CircleShape2D).radius = effective_range
	print("[TowerBase] active_spells count: ", active_spells.size(),
			"  AttackRange radius: ", effective_range)


func _get_target(attack_range: float, _mode: int) -> Node:
	var closest: Node = null
	var closest_dist := INF
	for enemy in _enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to((enemy as Node2D).global_position)
		if dist <= attack_range and dist < closest_dist:
			closest_dist = dist
			closest = enemy
	return closest


func _fire_spell(spell: SpellData) -> void:
	if spell.spell_category == Constants.SpellCategory.PROJECTILE:
		_fire_projectile(spell)
	elif spell.spell_category == Constants.SpellCategory.AOE_BURST:
		_fire_aoe(spell)
	elif spell.spell_category == Constants.SpellCategory.PERSISTENT_ZONE:
		_fire_persistent_zone(spell)
	elif spell.spell_category == Constants.SpellCategory.MINE:
		_fire_mine(spell)
	elif spell.spell_category == Constants.SpellCategory.PASSIVE:
		_fire_passive(spell)


func _fire_projectile(spell: SpellData) -> void:
	var target := _get_target(spell.range, Constants.TargetMode.CLOSEST)
	if target == null:
		return
	var proj: ProjectileBase = ObjectPool.acquire(_PROJECTILE_SCENE)
	var proj_parent: Node = _projectile_container if _projectile_container else get_parent()
	if proj.get_parent() != proj_parent:
		proj.reparent(proj_parent)
	proj.global_position = global_position
	proj.initialize(target, spell)


func _fire_mine(spell: SpellData) -> void:
	var mine_parent := _mine_container if _mine_container else get_parent()
	# Count only active (visible) mines
	var active_count := 0
	for child in mine_parent.get_children():
		if child.visible:
			active_count += 1
	# Remove oldest active mine if at cap
	if active_count >= Constants.MAX_MINES:
		for child in mine_parent.get_children():
			if child.visible:
				ObjectPool.release(child)
				break
	# Spawn at random position 300–600 px from tower
	var angle := randf() * TAU
	var dist := randf_range(300.0, 600.0)
	var mine_pos := global_position + Vector2(cos(angle), sin(angle)) * dist
	mine_pos = Vector2(clamp(mine_pos.x, 50.0, 1030.0), clamp(mine_pos.y, 50.0, 1870.0))
	var mine: LandMine = ObjectPool.acquire(_LAND_MINE_SCENE)
	if mine.get_parent() != mine_parent:
		mine.reparent(mine_parent)
	mine.global_position = mine_pos
	mine.initialize(spell)


func _fire_persistent_zone(spell: SpellData) -> void:
	var target := _get_target(spell.range, Constants.TargetMode.CLOSEST)
	if target == null:
		return
	var zone: PersistentZone = ObjectPool.acquire(_PERSISTENT_ZONE_SCENE)
	var zone_parent: Node = _zone_container if _zone_container else get_parent()
	if zone.get_parent() != zone_parent:
		zone.reparent(zone_parent)
	zone.initialize(target.global_position, spell.aoe_radius, spell)


func _fire_aoe(spell: SpellData) -> void:
	var target := _get_target(spell.range, Constants.TargetMode.CLOSEST)
	if target == null:
		return
	var zone: AoEZone = ObjectPool.acquire(_AOE_ZONE_SCENE)
	var zone_parent: Node = _zone_container if _zone_container else get_parent()
	if zone.get_parent() != zone_parent:
		zone.reparent(zone_parent)
	zone.initialize(target.global_position, spell.aoe_radius, spell)


func _fire_passive(_spell: SpellData) -> void:
	pass  # passives handled in add_spell → _apply_passive_effect, never reach here


func _on_attack_range_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		_enemies_in_range.append(body)


func _on_attack_range_body_exited(body: Node) -> void:
	if body is CharacterBody2D:
		_enemies_in_range.erase(body)


func _on_regen_timer_timeout() -> void:
	GameState.heal(GameState.tower_regen_per_sec)


func _draw() -> void:
	if $RangeIndicator.visible:
		draw_arc(Vector2.ZERO, 400.0, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.3), 2.0)

extends Area2D

const _PROJECTILE_SCENE := preload("res://scenes/spells/ProjectileBase.tscn")
const _AOE_ZONE_SCENE    := preload("res://scenes/spells/AoEZone.tscn")

var active_spells: Array
var _spell_cooldowns: Dictionary
var _enemies_in_range: Array
var _projectile_container: Node
var _zone_container: Node


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


func _physics_process(delta: float) -> void:
	for spell in active_spells:
		_spell_cooldowns[spell.spell_id] -= delta
		if _spell_cooldowns[spell.spell_id] <= 0.0:
			_spell_cooldowns[spell.spell_id] = spell.cooldown
			_fire_spell(spell)


func take_damage(amount: float) -> void:
	GameState.take_damage(amount)


func add_spell(spell: Resource) -> void:
	active_spells.append(spell)
	_spell_cooldowns[spell.spell_id] = 0.0


func _get_target(range: float, _mode: int) -> Node:
	var closest: Node = null
	var closest_dist := INF
	for enemy in _enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to((enemy as Node2D).global_position)
		if dist <= range and dist < closest_dist:
			closest_dist = dist
			closest = enemy
	return closest


func _fire_spell(spell: SpellData) -> void:
	if spell.spell_category == Constants.SpellCategory.PROJECTILE:
		_fire_projectile(spell)
	elif spell.spell_category == Constants.SpellCategory.AOE_BURST:
		_fire_aoe(spell)
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
	pass


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

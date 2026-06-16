class_name EnemyBase
extends CharacterBody2D

@export var base_hp: float         = 200.0
@export var base_speed: float      = 60.0
@export var base_damage: float     = 25.0
@export var attack_cooldown: float = 1.0
@export var armor_type: int        = Constants.ArmorType.MEDIUM
@export var xp_value: int          = 10
@export var enemy_type: int        = Constants.EnemyType.GRUNT

var hp: float
var _max_hp: float
var _attack_timer: float = 0.0
var _is_attacking: bool  = false
var _is_dead: bool       = false
var _tower_ref: Node

const _TOWER_POSITION    := Vector2(540.0, 960.0)
const _SEPARATION_RADIUS := 40.0


func _ready() -> void:
	add_to_group("enemies")
	hp     = base_hp * CombatUtils.calculate_wave_hp_scale(GameState.wave_number)
	_max_hp = hp

	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.RED)
	$Sprite2D.texture = ImageTexture.create_from_image(img)

	$HPBar.min_value = 0.0
	$HPBar.max_value = 100.0
	$HPBar.value     = 100.0

	$AttackZone.area_entered.connect(_on_attack_zone_area_entered)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if not _is_attacking:
		_move_toward_tower(delta)
	else:
		_attack_timer += delta
		if _attack_timer >= attack_cooldown:
			_attack_timer = 0.0
			if _tower_ref and is_instance_valid(_tower_ref):
				_tower_ref.take_damage(base_damage)
			else:
				GameState.take_damage(base_damage)


func _move_toward_tower(delta: float) -> void:
	var dir       := (_TOWER_POSITION - global_position).normalized()
	var sep       := _apply_separation(delta)
	var combined  := dir + sep
	if combined.length() > 0.0:
		combined = combined.normalized()
	velocity = combined * base_speed
	move_and_slide()


func _apply_separation(delta: float) -> Vector2:
	var push := Vector2.ZERO
	for enemy in WaveManager._active_enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		var diff := global_position - (enemy as Node2D).global_position
		var dist := diff.length()
		if dist < _SEPARATION_RADIUS and dist > 0.0:
			push += diff.normalized() * (_SEPARATION_RADIUS - dist)
	return push * delta


func take_damage(amount: float, damage_type: int) -> void:
	if _is_dead:
		return
	var hp_ratio := hp / _max_hp if _max_hp > 0.0 else 1.0
	var actual := CombatUtils.calculate_damage(amount, damage_type, armor_type, hp_ratio)
	hp -= actual
	$HPBar.visible = true
	$HPBar.value   = (hp / _max_hp) * 100.0
	if hp <= 0.0:
		die(damage_type)


func reset() -> void:
	hp = base_hp * CombatUtils.calculate_wave_hp_scale(GameState.wave_number)
	_max_hp = hp
	_is_attacking = false
	_is_dead      = false
	_attack_timer = 0.0
	_tower_ref = null
	velocity = Vector2.ZERO
	$HPBar.visible = false
	$HPBar.value = 100.0
	for child in find_children("*", "CollisionShape2D", true, false):
		child.set_deferred("disabled", false)


func die(killing_damage_type: int = Constants.DamageType.NORMAL) -> void:
	_is_attacking = false
	_tower_ref    = null
	if _is_dead:
		return
	_is_dead = true
	for child in find_children("*", "CollisionShape2D", true, false):
		child.set_deferred("disabled", true)
	if killing_damage_type == Constants.DamageType.PIERCING and GameState.pierce_heals_on_kill:
		GameState.heal(GameState.tower_max_hp * 0.005)
	EventBus.enemy_died.emit(self, global_position)
	EventBus.xp_gained.emit(xp_value)
	ObjectPool.release(self)


func _on_attack_zone_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		_is_attacking  = true
		velocity       = Vector2.ZERO
		_attack_timer  = 0.0
		_tower_ref     = area
		EventBus.enemy_reached_tower.emit(self)

extends CharacterBody2D

var max_hp: float           = 5000.0
var hp: float
var base_speed: float       = 40.0
var _current_speed: float   = 40.0
var base_damage: float      = 150.0
var _attack_cooldown: float = 2.0
var _attack_timer: float    = 0.0
var xp_value: int           = 200
var _phase: int             = 1
var _is_transitioning: bool = false
var _is_dead: bool          = false
var _tower_ref: Node

const _TOWER_POSITION := Vector2(540.0, 960.0)
const _ATTACK_RANGE   := 150.0


func _ready() -> void:
	add_to_group("enemies")
	hp     = max_hp * CombatUtils.calculate_wave_hp_scale(GameState.wave_number)
	max_hp = hp
	_current_speed = base_speed
	var img := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.0, 0.0))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	$HPBar.min_value = 0.0
	$HPBar.max_value = 100.0
	$HPBar.value     = 100.0
	$PhaseLabel.visible = false


func _physics_process(delta: float) -> void:
	if _is_dead or _is_transitioning:
		return
	var dist := global_position.distance_to(_TOWER_POSITION)
	if dist > _ATTACK_RANGE:
		var dir := (_TOWER_POSITION - global_position).normalized()
		velocity = dir * _current_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		_attack_timer += delta
		if _attack_timer >= _attack_cooldown:
			_attack_timer = 0.0
			if _tower_ref != null and is_instance_valid(_tower_ref):
				_tower_ref.take_damage(base_damage)
			else:
				GameState.take_damage(base_damage)


func take_damage(amount: float, damage_type: int) -> void:
	if _is_dead or _is_transitioning:
		return
	var actual := CombatUtils.calculate_damage(amount, damage_type, Constants.ArmorType.UNARMORED)
	hp -= actual
	$HPBar.value = (hp / max_hp) * 100.0
	if hp <= 0.0:
		die()
		return
	_check_phase_transition()


func _check_phase_transition() -> void:
	if _is_transitioning:
		return
	if _phase < 2 and hp <= max_hp * 0.66:
		_start_phase_transition(2)
	elif _phase < 3 and hp <= max_hp * 0.33:
		_start_phase_transition(3)


func _start_phase_transition(new_phase: int) -> void:
	_is_transitioning = true
	velocity = Vector2.ZERO
	$PhaseLabel.text    = "PHASE %d" % new_phase
	$PhaseLabel.visible = true
	var flash := create_tween().set_loops(3)
	flash.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1)
	flash.tween_property($Sprite2D, "modulate", Color(1.0, 0.0, 0.0), 0.1)
	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_callback(func() -> void:
		$Sprite2D.modulate  = Color(1.0, 0.0, 0.0)
		$PhaseLabel.visible = false
		_phase              = new_phase
		if new_phase == 2:
			_current_speed *= 1.3
			base_damage    *= 1.2
		else:
			_current_speed   *= 1.5
			_attack_cooldown *= 0.5
		_is_transitioning = false
	)


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	for child in find_children("*", "CollisionShape2D", true, false):
		child.set_deferred("disabled", true)
	EventBus.enemy_died.emit(self, global_position)
	EventBus.xp_gained.emit(xp_value)
	EventBus.boss_died.emit()
	queue_free()

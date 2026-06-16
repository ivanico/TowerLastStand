class_name ProjectileBase
extends Area2D

var damage: float = 10.0
var damage_type: int = Constants.DamageType.NORMAL
var speed: float = 700.0
var pierce_count: int = 0
var chain_count: int = 0

var _direction: Vector2 = Vector2.RIGHT
var _hits: int = 0
var _target: Node = null
var _chained_targets: Array = []
var _active: bool = false


func _ready() -> void:
	var img := Image.create(32, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color.YELLOW)
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)


func initialize(target: Node, spell: SpellData) -> void:
	_active = true
	_target = target
	_hits = 0
	_chained_targets = []
	damage      = spell.damage  # tower_damage_multiplier applied once in CombatUtils
	damage_type = spell.damage_type
	pierce_count = spell.pierce_count + GameState.global_pierce_bonus
	chain_count  = spell.chain_count  + GameState.global_chain_bonus
	if is_instance_valid(target):
		_direction = (target.global_position - global_position).normalized()
	else:
		_direction = Vector2.UP
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	if not body.is_in_group("enemies"):
		return
	body.take_damage(damage, damage_type)
	_chained_targets.append(body)
	_hits += 1
	if chain_count > 0:
		var next := _find_chain_target()
		if next != null:
			chain_count -= 1
			_direction = (next.global_position - global_position).normalized()
			rotation = _direction.angle()
			return
	if _hits > pierce_count:
		_release()


func _find_chain_target() -> Node:
	var closest: Node = null
	var closest_dist := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if not (enemy as Node2D).visible:
			continue
		if enemy in _chained_targets:
			continue
		var dist := global_position.distance_to((enemy as Node2D).global_position)
		if dist < 500.0 and dist < closest_dist:
			closest_dist = dist
			closest = enemy
	return closest


func _on_screen_exited() -> void:
	_release()


func _release() -> void:
	if not _active:
		return
	_active = false
	ObjectPool.release(self)

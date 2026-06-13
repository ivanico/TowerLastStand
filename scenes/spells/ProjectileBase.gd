class_name ProjectileBase
extends Area2D

var damage: float = 10.0
var damage_type: int = Constants.DamageType.NORMAL
var speed: float = 700.0
var pierce_count: int = 0

var _direction: Vector2 = Vector2.RIGHT
var _hits: int = 0
var _target: Node = null


func _ready() -> void:
	var img := Image.create(32, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color.YELLOW)
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)


func initialize(target: Node, spell: SpellData) -> void:
	_target = target
	_hits = 0
	damage = spell.damage * GameState.tower_damage_multiplier
	damage_type = spell.damage_type
	pierce_count = spell.pierce_count
	if is_instance_valid(target):
		_direction = (target.global_position - global_position).normalized()
	else:
		_direction = Vector2.UP
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage"):
		return
	body.take_damage(damage, damage_type)
	_hits += 1
	if _hits > pierce_count:
		ObjectPool.release(self)


func _on_screen_exited() -> void:
	ObjectPool.release(self)

class_name EnemyBrute
extends "res://scenes/enemies/EnemyBase.gd"

var _slow_stack: int = 0


func _ready() -> void:
	base_hp     = 800.0
	base_speed  = 35.0
	base_damage = 60.0
	armor_type  = Constants.ArmorType.HEAVY
	xp_value    = 40
	enemy_type  = Constants.EnemyType.BRUTE
	super._ready()
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.25, 0.25, 0.25))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	var shape := CapsuleShape2D.new()
	shape.height = 110.0
	shape.radius = 35.0
	$CollisionShape2D.shape = shape


func _move_toward_tower(delta: float) -> void:
	var effective_speed: float = base_speed * max(0.3, 1.0 - _slow_stack * 0.15)
	var dir      := (_TOWER_POSITION - global_position).normalized()
	var sep      := _apply_separation(delta)
	var combined := dir + sep
	if combined.length() > 0.0:
		combined = combined.normalized()
	velocity = combined * effective_speed
	move_and_slide()


func reset() -> void:
	_slow_stack = 0
	super.reset()

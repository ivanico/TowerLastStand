class_name EnemyRunner
extends "res://scenes/enemies/EnemyBase.gd"

var _zigzag_timer: float     = 0.0
var _zigzag_direction: float = 1.0


func _ready() -> void:
	base_hp     = 80.0
	base_speed  = 140.0
	base_damage = 15.0
	armor_type  = Constants.ArmorType.LIGHT
	xp_value    = 8
	enemy_type  = Constants.EnemyType.RUNNER
	super._ready()
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.YELLOW)
	$Sprite2D.texture = ImageTexture.create_from_image(img)


func _move_toward_tower(delta: float) -> void:
	_zigzag_timer += delta
	if _zigzag_timer >= 0.6:
		_zigzag_timer     = 0.0
		_zigzag_direction *= -1.0
	var dir := (_TOWER_POSITION - global_position).normalized()
	dir += dir.rotated(PI / 2.0) * _zigzag_direction * 0.4
	var sep      := _apply_separation(delta)
	var combined := dir.normalized() + sep
	if combined.length() > 0.0:
		combined = combined.normalized()
	velocity = combined * base_speed
	move_and_slide()


func reset() -> void:
	_zigzag_timer     = 0.0
	_zigzag_direction = 1.0
	super.reset()

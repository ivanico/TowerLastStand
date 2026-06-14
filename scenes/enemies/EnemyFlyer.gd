class_name EnemyFlyer
extends "res://scenes/enemies/EnemyBase.gd"


func _ready() -> void:
	base_hp     = 150.0
	base_speed  = 90.0
	base_damage = 20.0
	armor_type  = Constants.ArmorType.MEDIUM
	xp_value    = 15
	enemy_type  = Constants.EnemyType.FLYER
	super._ready()
	var img := Image.create(80, 80, false, Image.FORMAT_RGBA8)
	img.fill(Color.CYAN)
	$Sprite2D.texture = ImageTexture.create_from_image(img)


func _move_toward_tower(_delta: float) -> void:
	var dir := (_TOWER_POSITION - global_position).normalized()
	velocity = dir * base_speed
	move_and_slide()

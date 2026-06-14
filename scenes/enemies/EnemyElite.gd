class_name EnemyElite
extends "res://scenes/enemies/EnemyBase.gd"

var _shield_active: bool  = false
var _shield_hp: float     = 200.0


func _ready() -> void:
	base_hp     = 600.0
	base_speed  = 70.0
	base_damage = 45.0
	armor_type  = Constants.ArmorType.LIGHT
	xp_value    = 60
	enemy_type  = Constants.EnemyType.ELITE
	super._ready()
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.55, 0.0))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	_shield_active = true


func take_damage(amount: float, damage_type: int) -> void:
	if _shield_active:
		_shield_hp -= amount
		if _shield_hp <= 0.0:
			_shield_active = false
			var tw := create_tween()
			tw.tween_property($Sprite2D, "modulate", Color.WHITE, 0.05)
			tw.tween_property($Sprite2D, "modulate", Color(1.0, 0.55, 0.0), 0.2)
		return
	super.take_damage(amount, damage_type)


func reset() -> void:
	_shield_active = true
	_shield_hp     = 200.0
	super.reset()

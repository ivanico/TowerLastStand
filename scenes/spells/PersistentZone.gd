class_name PersistentZone
extends Area2D

var damage: float = 0.0
var damage_type: int = Constants.DamageType.NORMAL


func _ready() -> void:
	var img := Image.create(140, 140, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.7, 1.0, 0.25))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	$TickTimer.timeout.connect(_on_tick_timer_timeout)
	$DurationTimer.timeout.connect(_on_duration_timer_timeout)


func initialize(pos: Vector2, radius: float, spell: SpellData) -> void:
	$TickTimer.stop()
	$DurationTimer.stop()
	global_position = pos
	damage = spell.damage * GameState.tower_damage_multiplier
	damage_type = spell.damage_type
	($CollisionShape2D.shape as CircleShape2D).radius = radius
	$TickTimer.start()
	$DurationTimer.start(spell.duration)


func _on_tick_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(damage, damage_type)


func _on_duration_timer_timeout() -> void:
	$TickTimer.stop()
	ObjectPool.release(self)

class_name AoEZone
extends Area2D

var damage: float = 0.0
var damage_type: int = Constants.DamageType.NORMAL


func _ready() -> void:
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.5, 0.0, 0.4))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	$Timer.timeout.connect(func(): ObjectPool.release(self))


func initialize(pos: Vector2, radius: float, spell: SpellData) -> void:
	global_position = pos
	damage = spell.damage * GameState.tower_damage_multiplier
	damage_type = spell.damage_type
	($CollisionShape2D.shape as CircleShape2D).radius = radius
	_apply_damage.call_deferred()
	$Timer.start(0.3)


func _apply_damage() -> void:
	var radius := ($CollisionShape2D.shape as CircleShape2D).radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_to((enemy as Node2D).global_position) <= radius:
			enemy.take_damage(damage, damage_type)

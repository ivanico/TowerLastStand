class_name LandMine
extends Area2D

const _AOE_ZONE_SCENE := preload("res://scenes/spells/AoEZone.tscn")

var aoe_radius: float = 100.0
var _spell: SpellData
var _triggered: bool = false


func _ready() -> void:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.4, 0.4, 1.0))
	$Sprite2D.texture = ImageTexture.create_from_image(img)
	body_entered.connect(_on_body_entered)


func initialize(spell: SpellData) -> void:
	_spell = spell
	aoe_radius = spell.aoe_radius
	_triggered = false


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemies") or _triggered:
		return
	_triggered = true
	_explode.call_deferred()


func _explode() -> void:
	var zone: AoEZone = ObjectPool.acquire(_AOE_ZONE_SCENE)
	var zone_parent := get_parent()
	if zone.get_parent() != zone_parent:
		zone.reparent(zone_parent)
	zone.initialize(global_position, aoe_radius, _spell)
	ObjectPool.release(self)

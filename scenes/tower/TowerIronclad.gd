extends "res://scenes/tower/TowerBase.gd"

# Passive implemented in Epic 02


func _ready() -> void:
	super._ready()
	var img := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.25, 0.4))  # dark blue/grey placeholder
	$Sprite2D.texture = ImageTexture.create_from_image(img)

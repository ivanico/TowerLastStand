extends CanvasLayer


func _ready() -> void:
	var bg := ColorRect.new()
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.12, 0.0, 0.0, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "DEFEATED"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_right = 1.0
	title.offset_top   = 200.0
	title.offset_bottom = 320.0
	add_child(title)

	var panel := VBoxContainer.new()
	panel.anchor_left  = 0.1
	panel.anchor_right = 0.9
	panel.offset_top    = 460.0
	panel.offset_bottom = 760.0
	panel.add_theme_constant_override("separation", 24)
	add_child(panel)

	for text in [
		"Reached: Wave %d / %d" % [GameState.wave_number, Constants.TOTAL_WAVES],
		"Enemies Killed: %d"    % GameState.total_kills,
		"Partial Materials: +%d" % int(randi_range(3, 9) * GameState.materials_bonus_multiplier),
	]:
		var lbl := Label.new()
		lbl.text = text
		lbl.add_theme_font_size_override("font_size", 40)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(lbl)

	_add_button("Try Again",     900.0, _on_retry)
	_add_button("Return to Map", 1020.0, _on_map)


func _add_button(text: String, y: float, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 48)
	btn.anchor_left  = 0.15
	btn.anchor_right = 0.85
	btn.offset_top    = y
	btn.offset_bottom = y + 90.0
	btn.pressed.connect(callback)
	add_child(btn)


func _on_retry() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameWorld.tscn")


func _on_map() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameWorld.tscn")

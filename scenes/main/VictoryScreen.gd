extends CanvasLayer


func _ready() -> void:
	var bg := ColorRect.new()
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.0, 0.08, 0.22, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "VICTORY!"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_right  = 1.0
	title.offset_top    = 180.0
	title.offset_bottom = 300.0
	add_child(title)

	var panel := VBoxContainer.new()
	panel.anchor_left  = 0.1
	panel.anchor_right = 0.9
	panel.offset_top    = 420.0
	panel.offset_bottom = 800.0
	panel.add_theme_constant_override("separation", 24)
	add_child(panel)

	var chap_mats := randi_range(5, 15)
	var univ_mats := int(chap_mats * 0.2)
	for text in [
		"Waves Cleared: %d / %d"   % [Constants.TOTAL_WAVES, Constants.TOTAL_WAVES],
		"Enemies Killed: %d"        % GameState.total_kills,
		"Synergies Achieved: %d"    % GameState.active_synergies.size(),
		"Chapter Materials: +%d   Universal Materials: +%d" % [chap_mats, univ_mats],
	]:
		var lbl := Label.new()
		lbl.text = text
		lbl.add_theme_font_size_override("font_size", 38)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(lbl)

	var btn := Button.new()
	btn.text = "Return to Map"
	btn.add_theme_font_size_override("font_size", 48)
	btn.anchor_left  = 0.15
	btn.anchor_right = 0.85
	btn.offset_top    = 1000.0
	btn.offset_bottom = 1090.0
	btn.pressed.connect(_on_continue)
	add_child(btn)


func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/main/GameWorld.tscn")

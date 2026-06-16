extends CanvasLayer

var _chap_mats: int = 0
var _univ_mats: int = 0
var _awarded: bool  = false


func _ready() -> void:
	_chap_mats = int(randi_range(8, 15) * GameState.materials_bonus_multiplier)
	if GameState.perfect_run and GameState.bonus_cache_on_perfect_run:
		_chap_mats += 5
	_univ_mats = randi_range(1, 3)

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

	for text in [
		"Waves Cleared: %d / %d"   % [Constants.TOTAL_WAVES, Constants.TOTAL_WAVES],
		"Enemies Killed: %d"        % GameState.total_kills,
		"Synergies Achieved: %d"    % GameState.active_synergies.size(),
		"Chapter Materials: +%d   Universal Materials: +%d" % [_chap_mats, _univ_mats],
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




func _award_materials() -> void:
	if _awarded:
		return
	_awarded = true
	print("[VictoryScreen] perfect_run=%s, bonus_flag=%s, chap_mats=%d, univ_mats=%d" % [
		GameState.perfect_run, GameState.bonus_cache_on_perfect_run, _chap_mats, _univ_mats
	])
	MetaManager.add_materials(Constants.MaterialType.CHAPTER_MAT, _chap_mats)
	if _univ_mats > 0:
		MetaManager.add_materials(Constants.MaterialType.UNIVERSAL_MAT, _univ_mats)
	print("[VictoryScreen] Materials after award — chapter=%d, universal=%d" % [
		MetaManager.materials.get(Constants.MaterialType.CHAPTER_MAT, 0),
		MetaManager.materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0)
	])


func _on_continue() -> void:
	_award_materials()
	get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")

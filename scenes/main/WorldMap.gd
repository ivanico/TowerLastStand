extends CanvasLayer

var _energy_label: Label
var _no_energy_label: Label


func _ready() -> void:
	_build_ui()
	MetaManager.energy_changed.connect(_on_energy_changed)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.05, 0.12, 0.05, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "Tower's Last Stand"
	title.add_theme_font_size_override("font_size", 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_right  = 1.0
	title.offset_top    = 80.0
	title.offset_bottom = 160.0
	add_child(title)

	var energy_bar := HBoxContainer.new()
	energy_bar.offset_left   = 700.0
	energy_bar.offset_top    = 28.0
	energy_bar.offset_right  = 1060.0
	energy_bar.offset_bottom = 75.0
	energy_bar.add_theme_constant_override("separation", 8)
	add_child(energy_bar)

	var energy_icon := Label.new()
	energy_icon.text = "Energy:"
	energy_icon.add_theme_font_size_override("font_size", 30)
	energy_bar.add_child(energy_icon)

	_energy_label = Label.new()
	_energy_label.text = "%d / %d" % [MetaManager.energy, Constants.MAX_ENERGY]
	_energy_label.add_theme_font_size_override("font_size", 30)
	_energy_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	energy_bar.add_child(_energy_label)

	var chapter_panel := VBoxContainer.new()
	chapter_panel.anchor_left  = 0.1
	chapter_panel.anchor_right = 0.9
	chapter_panel.offset_top    = 640.0
	chapter_panel.offset_bottom = 1020.0
	chapter_panel.add_theme_constant_override("separation", 28)
	add_child(chapter_panel)

	var chapter_label := Label.new()
	chapter_label.text = "Chapter 1 — Plains"
	chapter_label.add_theme_font_size_override("font_size", 52)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_panel.add_child(chapter_label)

	var best: int = MetaManager.best_wave_per_chapter.get(1, 0)
	var best_text: String
	if best >= Constants.TOTAL_WAVES:
		best_text = "Best: Cleared! ✓"
	elif best > 0:
		best_text = "Best: Wave %d / %d" % [best, Constants.TOTAL_WAVES]
	else:
		best_text = "Not cleared yet"

	var best_label := Label.new()
	best_label.text = best_text
	best_label.add_theme_font_size_override("font_size", 36)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	chapter_panel.add_child(best_label)

	var start_btn := Button.new()
	start_btn.text = "Start Run  (Energy: 1)"
	start_btn.add_theme_font_size_override("font_size", 48)
	start_btn.custom_minimum_size = Vector2(0, 100)
	start_btn.pressed.connect(_on_start_pressed)
	chapter_panel.add_child(start_btn)

	_no_energy_label = Label.new()
	_no_energy_label.text = "Not enough energy!"
	_no_energy_label.add_theme_font_size_override("font_size", 36)
	_no_energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_no_energy_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	_no_energy_label.anchor_left  = 0.1
	_no_energy_label.anchor_right = 0.9
	_no_energy_label.offset_top    = 1060.0
	_no_energy_label.offset_bottom = 1110.0
	_no_energy_label.visible = false
	add_child(_no_energy_label)

	var garage_btn := Button.new()
	garage_btn.text = "Tower Garage"
	garage_btn.add_theme_font_size_override("font_size", 38)
	garage_btn.offset_left   = 30.0
	garage_btn.offset_top    = 1780.0
	garage_btn.offset_right  = 390.0
	garage_btn.offset_bottom = 1880.0
	garage_btn.pressed.connect(_on_garage_pressed)
	add_child(garage_btn)

	var codex_btn := Button.new()
	codex_btn.text = "Spell Codex"
	codex_btn.add_theme_font_size_override("font_size", 38)
	codex_btn.offset_left   = 690.0
	codex_btn.offset_top    = 1780.0
	codex_btn.offset_right  = 1050.0
	codex_btn.offset_bottom = 1880.0
	codex_btn.pressed.connect(_on_codex_pressed)
	add_child(codex_btn)


func _on_start_pressed() -> void:
	if not MetaManager.spend_energy():
		_no_energy_label.visible = true
		return
	_no_energy_label.visible = false
	get_tree().change_scene_to_file("res://scenes/main/GameWorld.tscn")


func _on_garage_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/TowerGarage.tscn")


func _on_codex_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/SpellCodex.tscn")


func _on_energy_changed(new_energy: int, max_energy: int) -> void:
	_energy_label.text = "%d / %d" % [new_energy, max_energy]
	if new_energy > 0:
		_no_energy_label.visible = false

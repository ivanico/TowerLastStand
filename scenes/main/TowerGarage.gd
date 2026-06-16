extends CanvasLayer

const TOWER_DATA_PATHS := {
	Constants.TowerID.IRONCLAD: "res://resources/towers/tower_ironclad.tres",
	Constants.TowerID.EMBER:    "res://resources/towers/tower_ember.tres",
	Constants.TowerID.TIDE:     "res://resources/towers/tower_tide.tres",
	Constants.TowerID.SENTINEL: "res://resources/towers/tower_sentinel.tres",
	Constants.TowerID.PHANTOM:  "res://resources/towers/tower_phantom.tres",
}

var _selected_tower_id: int

var _tower_name_label:   Label
var _star_label:         Label
var _stats_label:        Label
var _passive_label:      Label
var _cost_label:         Label
var _materials_label:    Label
var _upgrade_btn:        Button
var _select_btn:         Button


func _ready() -> void:
	_selected_tower_id = MetaManager.selected_tower_id
	_build_ui()
	_refresh_detail(_selected_tower_id)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.1, 0.1, 0.12, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "Tower Garage"
	title.add_theme_font_size_override("font_size", 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_right  = 1.0
	title.offset_top    = 50.0
	title.offset_bottom = 130.0
	add_child(title)

	# ── Left: tower list ──────────────────────────────────────────────────────
	var tower_list := VBoxContainer.new()
	tower_list.offset_left   = 20.0
	tower_list.offset_top    = 160.0
	tower_list.offset_right  = 290.0
	tower_list.offset_bottom = 1720.0
	tower_list.add_theme_constant_override("separation", 14)
	add_child(tower_list)

	for tower_id in MetaManager.owned_towers:
		var star := MetaManager.get_tower_star(tower_id)
		var data  := _load_tower_data(tower_id)
		var label := data.tower_name if data != null else "Tower %d" % tower_id

		var card := Button.new()
		card.text = "%s\n%s" % [label, _star_str(star)]
		card.add_theme_font_size_override("font_size", 26)
		card.custom_minimum_size = Vector2(0, 110)
		card.pressed.connect(_on_card_pressed.bind(tower_id))
		tower_list.add_child(card)

	# ── Right: detail panel ───────────────────────────────────────────────────
	var detail := VBoxContainer.new()
	detail.offset_left   = 310.0
	detail.offset_top    = 160.0
	detail.offset_right  = 1060.0
	detail.offset_bottom = 1710.0
	detail.add_theme_constant_override("separation", 22)
	add_child(detail)

	_tower_name_label = Label.new()
	_tower_name_label.add_theme_font_size_override("font_size", 54)
	_tower_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_child(_tower_name_label)

	_star_label = Label.new()
	_star_label.add_theme_font_size_override("font_size", 50)
	_star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_star_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	detail.add_child(_star_label)

	_stats_label = Label.new()
	_stats_label.add_theme_font_size_override("font_size", 34)
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
	detail.add_child(_stats_label)

	_passive_label = Label.new()
	_passive_label.add_theme_font_size_override("font_size", 28)
	_passive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_passive_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	detail.add_child(_passive_label)

	var sep := HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 12)
	detail.add_child(sep)

	_materials_label = Label.new()
	_materials_label.add_theme_font_size_override("font_size", 32)
	_materials_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_materials_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	detail.add_child(_materials_label)

	_cost_label = Label.new()
	_cost_label.add_theme_font_size_override("font_size", 30)
	_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cost_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.6))
	detail.add_child(_cost_label)

	_upgrade_btn = Button.new()
	_upgrade_btn.add_theme_font_size_override("font_size", 40)
	_upgrade_btn.custom_minimum_size = Vector2(0, 80)
	_upgrade_btn.pressed.connect(_on_upgrade_pressed)
	detail.add_child(_upgrade_btn)

	_select_btn = Button.new()
	_select_btn.add_theme_font_size_override("font_size", 40)
	_select_btn.custom_minimum_size = Vector2(0, 80)
	_select_btn.pressed.connect(_on_select_pressed)
	detail.add_child(_select_btn)

	# ── Back button ───────────────────────────────────────────────────────────
	var back_btn := Button.new()
	back_btn.text = "← Back"
	back_btn.add_theme_font_size_override("font_size", 40)
	back_btn.anchor_left  = 0.05
	back_btn.anchor_right = 0.45
	back_btn.offset_top    = 1780.0
	back_btn.offset_bottom = 1870.0
	back_btn.pressed.connect(_on_back_pressed)
	add_child(back_btn)


func _refresh_detail(tower_id: int) -> void:
	_selected_tower_id = tower_id
	var data    := _load_tower_data(tower_id)
	var star    := MetaManager.get_tower_star(tower_id)
	var ch_mats : int = MetaManager.materials.get(Constants.MaterialType.CHAPTER_MAT, 0)
	var un_mats : int = MetaManager.materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0)

	# Name & stars
	_tower_name_label.text = data.tower_name if data != null else "Tower %d" % tower_id
	_star_label.text       = _star_str(star)

	# Stats scaled to current star
	if data != null:
		var hp := data.base_hp
		for i in range(star - 1):
			hp += data.star_hp_bonus[i]
		var dmg_mult := 1.0
		for i in range(star - 1):
			dmg_mult += data.star_damage_bonus[i]
		_stats_label.text = "HP: %d   DMG: %.0f (×%.2f)   Range: %.0f" % [
			hp, data.base_damage, dmg_mult, data.base_range
		]
		# Passive — show the relevant tier
		if star >= 5 and data.passive_star5_description != "":
			_passive_label.text = data.passive_star5_description
		elif star >= 3 and data.passive_star3_description != "":
			_passive_label.text = data.passive_star3_description
		elif data.passive_description != "":
			_passive_label.text = data.passive_description
		else:
			_passive_label.text = ""
	else:
		_stats_label.text  = ""
		_passive_label.text = ""

	# Materials you own
	_materials_label.text = "Materials: %d Chapter / %d Universal" % [ch_mats, un_mats]

	# Upgrade section
	if star >= Constants.TOWER_MAX_STARS:
		_cost_label.text      = "Max Star reached"
		_upgrade_btn.text     = "Max ★"
		_upgrade_btn.disabled = true
	else:
		var cost     := MetaManager.get_tower_upgrade_cost(tower_id, star + 1)
		var cost_ch  : int = cost.get(Constants.MaterialType.CHAPTER_MAT, 0)
		var cost_un  : int = cost.get(Constants.MaterialType.UNIVERSAL_MAT, 0)
		var can_pay  := ch_mats >= cost_ch and un_mats >= cost_un
		_cost_label.text      = "Cost: %d Chapter   %d Universal" % [cost_ch, cost_un]
		_upgrade_btn.text     = "Upgrade to %s" % _star_str(star + 1)
		_upgrade_btn.disabled = not can_pay

	# Select section
	var already_selected := MetaManager.selected_tower_id == tower_id
	_select_btn.text     = "Selected ✓" if already_selected else "Select Tower"
	_select_btn.disabled = already_selected



func _star_str(star: int) -> String:
	return "★".repeat(star) + "☆".repeat(Constants.TOWER_MAX_STARS - star)


func _load_tower_data(tower_id: int) -> TowerData:
	var path: String = TOWER_DATA_PATHS.get(tower_id, "")
	if path == "" or not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as TowerData


func _on_card_pressed(tower_id: int) -> void:
	_refresh_detail(tower_id)


func _on_upgrade_pressed() -> void:
	if MetaManager.upgrade_tower_star(_selected_tower_id):
		_refresh_detail(_selected_tower_id)


func _on_select_pressed() -> void:
	MetaManager.selected_tower_id = _selected_tower_id
	MetaManager.save()
	_refresh_detail(_selected_tower_id)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")

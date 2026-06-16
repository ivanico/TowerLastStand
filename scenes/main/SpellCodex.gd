extends CanvasLayer

const FILTER_LABELS := ["All", "Normal", "Piercing", "Magic", "Siege", "Chaos"]
const DAMAGE_COLORS := [
	Color(0.85, 0.85, 0.85),  # Normal
	Color(1.0,  0.9,  0.3 ),  # Piercing
	Color(0.4,  0.6,  1.0 ),  # Magic
	Color(1.0,  0.5,  0.15),  # Siege
	Color(0.85, 0.3,  0.95),  # Chaos
]

var _current_filter:    int    = -1
var _selected_spell_id: String = ""
var _spell_grid:        GridContainer
var _filter_btns:       Array[Button] = []

var _detail_name_label:  Label
var _detail_rank_label:  Label
var _detail_desc_label:  Label
var _detail_mats_label:  Label
var _detail_cost_label:  Label
var _detail_lock_label:  Label
var _detail_rankup_btn:  Button


func _ready() -> void:
	_build_ui()
	_rebuild_grid(-1)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.anchor_right  = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.04, 0.06, 0.14, 1.0)
	add_child(bg)

	var title := Label.new()
	title.text = "Spell Codex"
	title.add_theme_font_size_override("font_size", 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.anchor_right  = 1.0
	title.offset_top    = 50.0
	title.offset_bottom = 120.0
	add_child(title)

	# ── Filter row ────────────────────────────────────────────────────────────
	var filter_row := HBoxContainer.new()
	filter_row.offset_left   = 8.0
	filter_row.offset_top    = 130.0
	filter_row.offset_right  = 1072.0
	filter_row.offset_bottom = 198.0
	filter_row.add_theme_constant_override("separation", 5)
	add_child(filter_row)

	for i in FILTER_LABELS.size():
		var filter_val := i - 1  # "All" maps to -1, rest map to DamageType index
		var btn := Button.new()
		btn.text = FILTER_LABELS[i]
		btn.add_theme_font_size_override("font_size", 22)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_filter_pressed.bind(filter_val))
		filter_row.add_child(btn)
		_filter_btns.append(btn)

	# ── Spell grid (scrollable) ───────────────────────────────────────────────
	var scroll := ScrollContainer.new()
	scroll.offset_left   = 8.0
	scroll.offset_top    = 206.0
	scroll.offset_right  = 1072.0
	scroll.offset_bottom = 960.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	_spell_grid = GridContainer.new()
	_spell_grid.columns = 3
	_spell_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_spell_grid.add_theme_constant_override("h_separation", 6)
	_spell_grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(_spell_grid)

	var sep := HSeparator.new()
	sep.offset_left   = 8.0
	sep.offset_top    = 966.0
	sep.offset_right  = 1072.0
	sep.offset_bottom = 974.0
	add_child(sep)

	# ── Detail panel ──────────────────────────────────────────────────────────
	var detail := VBoxContainer.new()
	detail.offset_left   = 20.0
	detail.offset_top    = 978.0
	detail.offset_right  = 1060.0
	detail.offset_bottom = 1760.0
	detail.add_theme_constant_override("separation", 14)
	add_child(detail)

	_detail_name_label = Label.new()
	_detail_name_label.text = "Tap a spell to see details"
	_detail_name_label.add_theme_font_size_override("font_size", 46)
	_detail_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.add_child(_detail_name_label)

	_detail_rank_label = Label.new()
	_detail_rank_label.add_theme_font_size_override("font_size", 36)
	_detail_rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_rank_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	detail.add_child(_detail_rank_label)

	_detail_desc_label = Label.new()
	_detail_desc_label.add_theme_font_size_override("font_size", 26)
	_detail_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_desc_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.72))
	detail.add_child(_detail_desc_label)

	_detail_mats_label = Label.new()
	_detail_mats_label.add_theme_font_size_override("font_size", 28)
	_detail_mats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_mats_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	detail.add_child(_detail_mats_label)

	_detail_cost_label = Label.new()
	_detail_cost_label.add_theme_font_size_override("font_size", 28)
	_detail_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_cost_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.55))
	detail.add_child(_detail_cost_label)

	_detail_lock_label = Label.new()
	_detail_lock_label.text = "Draft this spell in a run to unlock"
	_detail_lock_label.add_theme_font_size_override("font_size", 28)
	_detail_lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_lock_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	_detail_lock_label.visible = false
	detail.add_child(_detail_lock_label)

	_detail_rankup_btn = Button.new()
	_detail_rankup_btn.text = "Rank Up"
	_detail_rankup_btn.add_theme_font_size_override("font_size", 40)
	_detail_rankup_btn.custom_minimum_size = Vector2(0, 80)
	_detail_rankup_btn.disabled = true
	_detail_rankup_btn.pressed.connect(_on_rankup_pressed)
	detail.add_child(_detail_rankup_btn)

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


func _rebuild_grid(filter_type: int) -> void:
	_current_filter = filter_type

	# Highlight active filter button (index 0 = "All" = filter -1)
	var active_idx := filter_type + 1
	for i in _filter_btns.size():
		_filter_btns[i].modulate = Color(1.0, 0.85, 0.3) if i == active_idx else Color.WHITE

	for child in _spell_grid.get_children():
		child.queue_free()

	for spell in SpellRegistry.all_spells:
		if filter_type != -1 and spell.damage_type != filter_type:
			continue
		_add_spell_card(spell)


func _add_spell_card(spell: SpellData) -> void:
	var discovered := spell.spell_id in MetaManager.discovered_spells
	var rank       := MetaManager.get_spell_rank(spell.spell_id)

	var card := Button.new()
	card.custom_minimum_size       = Vector2(0, 105)
	card.size_flags_horizontal     = Control.SIZE_EXPAND_FILL

	if discovered:
		var col: Color = DAMAGE_COLORS[spell.damage_type] if spell.damage_type < DAMAGE_COLORS.size() else Color.WHITE
		card.text = "%s\n%s" % [spell.spell_name, _rank_dots(rank)]
		card.add_theme_color_override("font_color", col)
	else:
		card.text = "???\n%s" % _rank_dots(0)
		card.add_theme_color_override("font_color", Color(0.38, 0.38, 0.38))

	card.add_theme_font_size_override("font_size", 21)
	card.pressed.connect(_on_card_pressed.bind(spell.spell_id))
	_spell_grid.add_child(card)


func _refresh_detail(spell_id: String) -> void:
	_selected_spell_id = spell_id
	var spell := SpellRegistry.get_spell(spell_id)
	if spell == null:
		return
	var ranked_spell := SpellRegistry.get_spell_for_run(spell_id)

	var discovered := spell_id in MetaManager.discovered_spells
	var rank       := MetaManager.get_spell_rank(spell_id)
	var ch_mats: int = MetaManager.materials.get(Constants.MaterialType.CHAPTER_MAT, 0)
	var un_mats: int = MetaManager.materials.get(Constants.MaterialType.UNIVERSAL_MAT, 0)

	if discovered:
		var col: Color = DAMAGE_COLORS[spell.damage_type] if spell.damage_type < DAMAGE_COLORS.size() else Color.WHITE
		_detail_name_label.text = spell.spell_name
		_detail_name_label.add_theme_color_override("font_color", col)
	else:
		_detail_name_label.text = "???"
		_detail_name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	_detail_rank_label.text = "Rank %d   %s" % [rank, _rank_dots(rank)]

	# Description: use field if present, otherwise derive from ranked stats
	var desc := spell.description
	if desc == "" and discovered:
		desc = "DMG: %.0f   CD: %.2fs   Range: %.0f" % [ranked_spell.damage, ranked_spell.cooldown, ranked_spell.range]
		if ranked_spell.chain_count > 0:
			desc += "   Chains: %d" % ranked_spell.chain_count
		if ranked_spell.pierce_count > 0:
			desc += "   Pierce: %d" % ranked_spell.pierce_count
	_detail_desc_label.text = desc if discovered else ""

	_detail_mats_label.text  = "Materials: %d Chapter / %d Universal" % [ch_mats, un_mats]
	_detail_lock_label.visible = not discovered

	if not discovered:
		_detail_cost_label.text      = ""
		_detail_rankup_btn.text      = "Rank Up"
		_detail_rankup_btn.disabled  = true
	elif rank >= Constants.SPELL_MAX_RANK:
		_detail_cost_label.text      = "Max Rank reached"
		_detail_rankup_btn.text      = "Max Rank"
		_detail_rankup_btn.disabled  = true
	else:
		var cost    := MetaManager.get_spell_rank_cost(spell_id, rank + 1)
		var cost_ch : int = cost.get(Constants.MaterialType.CHAPTER_MAT, 0)
		var cost_un : int = cost.get(Constants.MaterialType.UNIVERSAL_MAT, 0)
		var can_pay := ch_mats >= cost_ch and un_mats >= cost_un
		_detail_cost_label.text     = "Cost: %d Chapter   %d Universal" % [cost_ch, cost_un]
		_detail_rankup_btn.text     = "Rank Up  →  %s" % _rank_dots(rank + 1)
		_detail_rankup_btn.disabled = not can_pay


func _rank_dots(rank: int) -> String:
	return "●".repeat(rank) + "○".repeat(Constants.SPELL_MAX_RANK - rank)


func _on_card_pressed(spell_id: String) -> void:
	_refresh_detail(spell_id)


func _on_filter_pressed(filter_type: int) -> void:
	_rebuild_grid(filter_type)


func _on_rankup_pressed() -> void:
	if MetaManager.upgrade_spell_rank(_selected_spell_id):
		_rebuild_grid(_current_filter)
		_refresh_detail(_selected_spell_id)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/WorldMap.tscn")

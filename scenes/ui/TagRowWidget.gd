extends HBoxContainer

const TAG_NAMES: Dictionary = {
	Constants.SynergyTag.FIRE:      "Fire",
	Constants.SynergyTag.CHAIN:     "Chain",
	Constants.SynergyTag.PIERCING:  "Pierce",
	Constants.SynergyTag.HEAVY:     "Heavy",
	Constants.SynergyTag.ARMOR:     "Armor",
	Constants.SynergyTag.OFFENSE:   "Offense",
	Constants.SynergyTag.UTILITY:   "Utility",
	Constants.SynergyTag.GOLD:      "Gold",
	Constants.SynergyTag.CHAOS_TAG: "Chaos",
}

const TAG_COLORS: Dictionary = {
	Constants.SynergyTag.FIRE:      Color(1.0, 0.3, 0.1),
	Constants.SynergyTag.CHAIN:     Color(0.4, 0.8, 1.0),
	Constants.SynergyTag.PIERCING:  Color(1.0, 1.0, 0.3),
	Constants.SynergyTag.HEAVY:     Color(0.55, 0.55, 0.55),
	Constants.SynergyTag.ARMOR:     Color(0.3, 0.6, 1.0),
	Constants.SynergyTag.OFFENSE:   Color(1.0, 0.5, 0.0),
	Constants.SynergyTag.UTILITY:   Color(0.5, 1.0, 0.5),
	Constants.SynergyTag.GOLD:      Color(1.0, 0.85, 0.0),
	Constants.SynergyTag.CHAOS_TAG: Color(0.7, 0.0, 1.0),
}

var _tag_widgets: Dictionary = {}  # { tag_int: HBoxContainer }


func _ready() -> void:
	GameState.tag_count_changed.connect(update_tag)
	EventBus.synergy_threshold_reached.connect(
		func(tag: int, _level: int) -> void: highlight_tag(tag))


func update_tag(tag: int, count: int) -> void:
	var widget: HBoxContainer
	if _tag_widgets.has(tag):
		widget = _tag_widgets[tag]
	else:
		widget = _make_widget(tag)
		_tag_widgets[tag] = widget
		add_child(widget)
	widget.get_node("CountLabel").text = "%s x%d" % [TAG_NAMES.get(tag, "?"), count]
	if count == Constants.SYNERGY_THRESHOLD_LOW - 1 or count == Constants.SYNERGY_THRESHOLD_HIGH - 1:
		_pulse(widget)


func highlight_tag(tag: int) -> void:
	if not _tag_widgets.has(tag):
		return
	var dot: ColorRect = _tag_widgets[tag].get_node("Dot")
	var orig: Color = TAG_COLORS.get(tag, Color.WHITE)
	var tween := create_tween()
	tween.tween_property(dot, "color", Color.WHITE, 0.1)
	tween.tween_property(dot, "color", orig, 0.4)


func _make_widget(tag: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "Tag_%d" % tag
	row.add_theme_constant_override("separation", 4)
	var dot := ColorRect.new()
	dot.name = "Dot"
	dot.custom_minimum_size = Vector2(14, 14)
	dot.color = TAG_COLORS.get(tag, Color.WHITE)
	row.add_child(dot)
	var lbl := Label.new()
	lbl.name = "CountLabel"
	lbl.add_theme_font_size_override("font_size", 18)
	row.add_child(lbl)
	return row


func _pulse(widget: HBoxContainer) -> void:
	var tween := create_tween().set_loops(3)
	tween.tween_property(widget, "modulate", Color(1.5, 1.5, 0.5), 0.25)
	tween.tween_property(widget, "modulate", Color.WHITE, 0.25)

class_name DraftCard
extends PanelContainer

signal card_selected(card_data: Resource)

var _card_data: Resource


func _ready() -> void:
	$VBox/SynergyHint.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	$VBox/SelectButton.pressed.connect(_on_select_button_pressed)


func setup(data: Resource) -> void:
	_card_data = data

	var name_text: String
	var desc_text: String
	var rarity: int
	var tags: Array

	if data is SpellData:
		name_text = data.spell_name
		desc_text = data.description
		rarity    = data.rarity
		tags      = data.tags
	elif data is StatUpgradeData:
		name_text = data.upgrade_name
		desc_text = data.description
		rarity    = data.rarity
		tags      = data.tags
	else:
		return

	$VBox/CardName.text      = name_text
	$VBox/Description.text   = desc_text
	$VBox/RarityBorder.color = _rarity_color(rarity)

	for child in $VBox/TagContainer.get_children():
		child.queue_free()
	for tag in tags:
		var chip := Label.new()
		chip.text = _tag_name(tag)
		$VBox/TagContainer.add_child(chip)

	$VBox/SynergyHint.visible = false
	for tag in tags:
		var count: int = GameState.tag_counts.get(tag, 0)
		if count == 2 or count == 4:
			$VBox/SynergyHint.visible = true
			break

	print("[DraftCard] setup: '", name_text, "'  rarity=", rarity,
			" (0=Common grey  1=Rare blue  2=Epic purple)")


func _on_select_button_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
	card_selected.emit(_card_data)


func _rarity_color(rarity: int) -> Color:
	match rarity:
		Constants.CardRarity.COMMON: return Color(0.55, 0.55, 0.55)
		Constants.CardRarity.RARE:   return Color(0.2,  0.5,  1.0)
		Constants.CardRarity.EPIC:   return Color(0.65, 0.1,  0.85)
	return Color(0.55, 0.55, 0.55)


func _tag_name(tag: int) -> String:
	match tag:
		Constants.SynergyTag.FIRE:     return "[Fire]"
		Constants.SynergyTag.CHAIN:    return "[Chain]"
		Constants.SynergyTag.PIERCING: return "[Piercing]"
		Constants.SynergyTag.HEAVY:    return "[Heavy]"
		Constants.SynergyTag.ARMOR:    return "[Armor]"
		Constants.SynergyTag.OFFENSE:  return "[Offense]"
		Constants.SynergyTag.UTILITY:  return "[Utility]"
		Constants.SynergyTag.GOLD:     return "[Gold]"
		Constants.SynergyTag.CHAOS_TAG: return "[Chaos]"
	return "?"

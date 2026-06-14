extends CanvasLayer

# Keys: "%d_%d" % [SynergyTag enum value, threshold level]
const _TEXTS: Dictionary = {
	# FIRE = 0
	"0_3": "[Fire]x3 — Magic spells +25% damage!",
	"0_5": "[Fire]x5 — Enemies killed by Fire leave a Burn patch!",
	# CHAIN = 1
	"1_3": "[Chain]x3 — Chain effects jump +1 extra time!",
	"1_5": "[Chain]x5 — Chain jumps apply a damage type debuff!",
	# PIERCING = 2
	"2_3": "[Piercing]x3 — Piercing projectiles pass through +1 enemy!",
	"2_5": "[Piercing]x5 — Pierce kills restore 0.5% max HP!",
	# HEAVY = 3
	"3_3": "[Heavy]x3 — Siege attacks +40% damage!",
	"3_5": "[Heavy]x5 — Siege attacks stun for 0.3 sec!",
	# ARMOR = 4
	"4_3": "[Armor]x3 — Tower takes 15% less damage!",
	"4_5": "[Armor]x5 — Tower regens 1% max HP every 5 sec!",
	# OFFENSE = 5
	"5_3": "[Offense]x3 — All damage +10%!",
	"5_5": "[Offense]x5 — Every 10th shot fires a bonus projectile!",
	# UTILITY = 6
	"6_3": "[Utility]x3 — Spell cooldowns -10%!",
	"6_5": "[Utility]x5 — Draft pool shows 4 cards!",
	# GOLD = 7
	"7_3": "[Gold]x3 — +30% materials earned end of run!",
	"7_5": "[Gold]x5 — Bonus cache if run cleared without dying!",
	# CHAOS_TAG = 8
	"8_3": "[Chaos]x3 — Chaos spells +50% damage!",
	"8_5": "[Chaos]x5 — 15% chance to instantly kill non-boss enemies!",
}

const _HIDDEN_Y := -120.0
const _SHOWN_Y  := 40.0


func _ready() -> void:
	EventBus.synergy_threshold_reached.connect(show_synergy)


func show_synergy(tag: int, level: int) -> void:
	var key := "%d_%d" % [tag, level]
	if not _TEXTS.has(key):
		return
	var panel := $BannerPanel
	$BannerPanel/BannerLabel.text = _TEXTS[key]
	panel.position.y = _HIDDEN_Y
	panel.visible = true
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(panel, "position:y", _SHOWN_Y, 0.35).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(panel, "position:y", _HIDDEN_Y, 0.35).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: panel.visible = false)

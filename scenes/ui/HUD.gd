extends CanvasLayer


func _ready() -> void:
	GameState.hp_changed.connect(_on_hp_changed)
	GameState.xp_bar_updated.connect(_on_xp_bar_updated)
	EventBus.wave_started.connect(_on_wave_started)


func _on_hp_changed(hp: int, max_hp: int) -> void:
	if max_hp == 0:
		return
	var tween := create_tween()
	tween.tween_property($HPBar, "value", (float(hp) / float(max_hp)) * 100.0, 0.2)
	$HPLabel.text = "%d / %d" % [hp, max_hp]


func _on_xp_bar_updated(current: int, needed: int) -> void:
	if needed == 0:
		return
	var tween := create_tween()
	tween.tween_property($XPBar, "value", (float(current) / float(needed)) * 100.0, 0.2)
	$LevelLabel.text = "Lv.%d" % GameState.run_level


func _on_wave_started(wave_number: int) -> void:
	$WaveLabel.text = "Wave %d / %d" % [wave_number, Constants.TOTAL_WAVES]

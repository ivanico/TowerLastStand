extends Node2D

const _PROJECTILE_SCENE  := preload("res://scenes/spells/ProjectileBase.tscn")
const _AOE_ZONE_SCENE    := preload("res://scenes/spells/AoEZone.tscn")
const _ENEMY_GRUNT_SCENE := preload("res://scenes/enemies/EnemyGrunt.tscn")


func _ready() -> void:
	WaveManager._enemy_container = $EnemyContainer
	WaveManager._tower_node = $TowerNode
	GameState.tower_node = $TowerNode
	$TowerNode._projectile_container = $ProjectileContainer
	$TowerNode._zone_container = $ZoneContainer
	ObjectPool.preload_pool(_PROJECTILE_SCENE, 30)
	ObjectPool.preload_pool(_AOE_ZONE_SCENE, 10)
	ObjectPool.preload_pool(_ENEMY_GRUNT_SCENE, 30)
	var test_spell := SpellData.new()
	test_spell.spell_id       = "test_bolt"
	test_spell.spell_name     = "Test Bolt"
	test_spell.damage         = 50.0
	test_spell.damage_type    = Constants.DamageType.NORMAL
	test_spell.spell_category = Constants.SpellCategory.PROJECTILE
	test_spell.cooldown       = 1.0
	test_spell.range          = 450.0
	test_spell.pierce_count   = 0
	$TowerNode.add_spell(test_spell)

	GameState.start_run(null)
	WaveManager.start_wave(GameState.wave_number)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.tower_died.connect(_on_tower_died)


func _on_wave_cleared(wave_number: int) -> void:
	if wave_number >= Constants.TOTAL_WAVES:
		return
	GameState.wave_number += 1
	DraftManager.open_draft("wave_clear")


func _on_phase_changed(_phase: int) -> void:
	pass


func _on_tower_died() -> void:
	WaveManager.clear_all_enemies()

	var canvas := CanvasLayer.new()
	canvas.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(canvas)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.65)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)

	var label := Label.new()
	label.text = "GAME OVER\nTap to retry"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 72)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(label)

	var btn := Button.new()
	btn.flat = true
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.pressed.connect(func() -> void:
		get_tree().paused = false
		GameState.reset()
		get_tree().reload_current_scene()
	)
	canvas.add_child(btn)

	get_tree().paused = true

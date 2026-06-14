extends Node2D

const _PROJECTILE_SCENE      := preload("res://scenes/spells/ProjectileBase.tscn")
const _AOE_ZONE_SCENE        := preload("res://scenes/spells/AoEZone.tscn")
const _PERSISTENT_ZONE_SCENE := preload("res://scenes/spells/PersistentZone.tscn")
const _LAND_MINE_SCENE       := preload("res://scenes/spells/LandMine.tscn")
const _DRAFT_UI_SCENE        := preload("res://scenes/ui/DraftUI.tscn")
const _SYNERGY_BANNER_SCENE  := preload("res://scenes/ui/SynergyBanner.tscn")
const _CHAPTER_01            := preload("res://resources/waves/chapter_01.tres")


func _ready() -> void:
	WaveManager.setup($EnemyContainer, $TowerNode, _CHAPTER_01 as ChapterConfig)
	GameState.tower_node = $TowerNode
	$TowerNode._projectile_container = $ProjectileContainer
	$TowerNode._zone_container = $ZoneContainer
	$TowerNode._mine_container = $MineContainer
	ObjectPool.preload_pool(_PROJECTILE_SCENE, 30)
	ObjectPool.preload_pool(_AOE_ZONE_SCENE, 10)
	ObjectPool.preload_pool(_PERSISTENT_ZONE_SCENE, 10)
	ObjectPool.preload_pool(_LAND_MINE_SCENE, 10)
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

	add_child(_SYNERGY_BANNER_SCENE.instantiate())
	add_child(_DRAFT_UI_SCENE.instantiate())
	GameState.start_run(null)
	WaveManager.start_wave(GameState.wave_number)
	EventBus.wave_cleared.connect(_on_wave_cleared)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.tower_died.connect(_on_tower_died)
	EventBus.level_up.connect(_on_level_up)
	EventBus.boss_died.connect(_on_boss_died)


func _on_wave_cleared(wave_number: int) -> void:
	if wave_number >= Constants.TOTAL_WAVES:
		return
	GameState.wave_number += 1
	DraftManager.open_draft("wave_clear")


func _on_phase_changed(phase: int) -> void:
	if phase == Constants.GamePhase.DRAFT and DraftManager._draft_trigger == "wave_clear":
		WaveManager.stop_wave()


func _on_level_up(_level: int) -> void:
	DraftManager.open_draft("level_up")


func _on_tower_died() -> void:
	WaveManager.stop_wave()
	GameState.end_run(false)
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/main/DefeatScreen.tscn")


func _on_boss_died() -> void:
	_trigger_victory()


func _trigger_victory() -> void:
	WaveManager.stop_wave()
	GameState.end_run(true)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main/VictoryScreen.tscn")

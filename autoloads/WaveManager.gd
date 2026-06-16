extends Node

var _active_enemies: Array
var _trickle_timer: Timer
var _enemy_container: Node
var _tower_ref: Node
var _current_wave_config: WaveConfig
var _chapter_config: ChapterConfig
var _trickle_remaining: int = 0
var _wave_number: int = 0

const _BOSS_SCENE:   PackedScene = preload("res://scenes/enemies/EnemyBoss.tscn")
const _GRUNT_SCENE:  PackedScene = preload("res://scenes/enemies/EnemyGrunt.tscn")
const _RUNNER_SCENE: PackedScene = preload("res://scenes/enemies/EnemyRunner.tscn")
const _BRUTE_SCENE:  PackedScene = preload("res://scenes/enemies/EnemyBrute.tscn")
const _FLYER_SCENE:  PackedScene = preload("res://scenes/enemies/EnemyFlyer.tscn")
const _ELITE_SCENE:  PackedScene = preload("res://scenes/enemies/EnemyElite.tscn")

const _ARENA_CENTER := Vector2(540.0, 960.0)
const _ARENA_HALF_W := 450.0
const _ARENA_HALF_H := 800.0


func _ready() -> void:
	_trickle_timer = Timer.new()
	_trickle_timer.one_shot = false
	_trickle_timer.timeout.connect(_on_trickle_timer_timeout)
	add_child(_trickle_timer)
	EventBus.enemy_died.connect(_on_enemy_died)


func setup(enemy_container: Node, tower: Node, chapter: ChapterConfig) -> void:
	_enemy_container = enemy_container
	_tower_ref = tower
	_chapter_config = chapter
	ObjectPool.preload_pool(_GRUNT_SCENE, 20)
	ObjectPool.preload_pool(_RUNNER_SCENE, 15)
	ObjectPool.preload_pool(_BRUTE_SCENE, 8)
	ObjectPool.preload_pool(_FLYER_SCENE, 10)
	ObjectPool.preload_pool(_ELITE_SCENE, 5)


func start_wave(wave_number: int) -> void:
	if _chapter_config == null:
		push_error("WaveManager: setup() not called before start_wave()")
		return
	_wave_number = wave_number
	_active_enemies.clear()
	_current_wave_config = _chapter_config.waves[wave_number - 1]
	_log_wave_info()
	if _current_wave_config.is_boss_wave:
		_spawn_boss()
		EventBus.wave_started.emit(wave_number)
		return
	_trickle_remaining = _current_wave_config.trickle_count
	_spawn_burst(_current_wave_config.burst_count)
	if _trickle_remaining > 0:
		_trickle_timer.wait_time = _current_wave_config.trickle_interval
		_trickle_timer.start()
	EventBus.wave_started.emit(wave_number)


func stop_wave() -> void:
	_trickle_timer.stop()
	_trickle_remaining = 0
	clear_all_enemies()


func clear_all_enemies() -> void:
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			ObjectPool.release(enemy)
	_active_enemies.clear()


func _log_wave_info() -> void:
	var cfg := _current_wave_config
	if cfg.is_boss_wave:
		print("Wave %d: BOSS WAVE" % _wave_number)
		return
	var counts: Dictionary = {}
	for type in cfg.enemy_pool:
		counts[type] = counts.get(type, 0) + 1
	var parts: Array[String] = []
	for type in counts:
		parts.append("%s×%d" % [_type_name(type), counts[type]])
	var total := cfg.burst_count + cfg.trickle_count
	print("Wave %d: %d total (%d burst + %d trickle) — pool [%s]" % [
		_wave_number, total, cfg.burst_count, cfg.trickle_count,
		", ".join(parts)
	])


func _type_name(type: int) -> String:
	match type:
		Constants.EnemyType.GRUNT:  return "Grunt"
		Constants.EnemyType.RUNNER: return "Runner"
		Constants.EnemyType.BRUTE:  return "Brute"
		Constants.EnemyType.FLYER:  return "Flyer"
		Constants.EnemyType.ELITE:  return "Elite"
	return "Unknown"


func _spawn_burst(count: int) -> void:
	var pool := _current_wave_config.enemy_pool
	if pool.is_empty():
		return
	for i in count:
		var type: int = pool[randi() % pool.size()]
		_spawn_enemy(type)


func _on_trickle_timer_timeout() -> void:
	if _trickle_remaining <= 0:
		_trickle_timer.stop()
		return
	var pool := _current_wave_config.enemy_pool
	if not pool.is_empty():
		var type: int = pool[randi() % pool.size()]
		_spawn_enemy(type)
	_trickle_remaining -= 1
	if _trickle_remaining <= 0:
		_trickle_timer.stop()


func _spawn_enemy(type: int) -> void:
	var scene: PackedScene
	match type:
		Constants.EnemyType.GRUNT:  scene = _GRUNT_SCENE
		Constants.EnemyType.RUNNER: scene = _RUNNER_SCENE
		Constants.EnemyType.BRUTE:  scene = _BRUTE_SCENE
		Constants.EnemyType.FLYER:  scene = _FLYER_SCENE
		Constants.EnemyType.ELITE:  scene = _ELITE_SCENE
		_:                           scene = _GRUNT_SCENE
	var enemy: Node = ObjectPool.acquire(scene)
	var target: Node = _enemy_container if _enemy_container else self
	if enemy.get_parent() != target:
		enemy.reparent(target)
	(enemy as Node2D).global_position = _get_spawn_position()
	enemy.reset()
	enemy._tower_ref = _tower_ref
	_apply_wave_scaling(enemy, _wave_number)
	_active_enemies.append(enemy)


func _apply_wave_scaling(enemy: Node, wave: int) -> void:
	enemy.hp     = enemy.base_hp * CombatUtils.calculate_wave_hp_scale(wave)
	enemy._max_hp = enemy.hp


func _get_spawn_position() -> Vector2:
	var hw := _ARENA_HALF_W
	var hh := _ARENA_HALF_H
	var cx := _ARENA_CENTER.x
	var cy := _ARENA_CENTER.y
	var t   := randf() * (hw * 4.0 + hh * 4.0)
	if t < hw * 2.0:
		return Vector2(cx - hw + t, cy - hh)
	t -= hw * 2.0
	if t < hh * 2.0:
		return Vector2(cx + hw, cy - hh + t)
	t -= hh * 2.0
	if t < hw * 2.0:
		return Vector2(cx + hw - t, cy + hh)
	t -= hw * 2.0
	return Vector2(cx - hw, cy + hh - t)


func _on_enemy_died(enemy: Node, _pos: Vector2) -> void:
	_active_enemies.erase(enemy)
	if _active_enemies.is_empty() and _trickle_remaining <= 0:
		_trickle_timer.stop()
		if GameState.phase == Constants.GamePhase.BOSS:
			return  # victory handled by boss_died → Task 04-07
		EventBus.wave_cleared.emit(GameState.wave_number)


func _spawn_boss() -> void:
	var boss := _BOSS_SCENE.instantiate()
	boss.global_position = Vector2(540.0, -150.0)
	boss._tower_ref = _tower_ref
	var target := _enemy_container if _enemy_container else self
	target.add_child(boss)
	_active_enemies.append(boss)
	GameState.phase = Constants.GamePhase.BOSS
	EventBus.phase_changed.emit(Constants.GamePhase.BOSS)
	EventBus.boss_spawned.emit()
	print("Wave 20: Boss spawned — hp=%.0f, boss_spawned emitted, phase=BOSS" % boss.hp)

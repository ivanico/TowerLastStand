extends Node

var _active_enemies: Array
var _trickle_timer: Timer
var _enemy_container: Node
var _tower_node: Node

var _total_to_spawn: int = 0
var _spawned_count: int  = 0
var _total_killed: int   = 0

const _GRUNT_SCENE: PackedScene = preload("res://scenes/enemies/EnemyGrunt.tscn")

const _BURST_COUNT:    int = 5
const _TRICKLE_BUDGET: int = 3

# Arena perimeter constants (900 × 1600, centered on 540, 960)
const _ARENA_CENTER  := Vector2(540.0, 960.0)
const _ARENA_HALF_W  := 450.0
const _ARENA_HALF_H  := 800.0


func _ready() -> void:
	_trickle_timer = Timer.new()
	_trickle_timer.wait_time = 3.0
	_trickle_timer.one_shot = false
	_trickle_timer.timeout.connect(_on_trickle_timer_timeout)
	add_child(_trickle_timer)
	EventBus.enemy_died.connect(_on_enemy_died)


func start_wave(wave_number: int) -> void:
	_active_enemies.clear()
	_total_to_spawn = _BURST_COUNT + _TRICKLE_BUDGET
	_spawned_count  = 0
	_total_killed   = 0
	for i in _BURST_COUNT:
		_spawn_enemy()
	_trickle_timer.start()
	EventBus.wave_started.emit(wave_number)


func stop_wave() -> void:
	_trickle_timer.stop()
	clear_all_enemies()


func clear_all_enemies() -> void:
	for enemy in _active_enemies:
		if is_instance_valid(enemy):
			ObjectPool.release(enemy)
	_active_enemies.clear()


func _spawn_enemy() -> void:
	if _spawned_count >= _total_to_spawn:
		return
	var enemy: Node = ObjectPool.acquire(_GRUNT_SCENE)
	var target: Node = _enemy_container if _enemy_container else self
	if enemy.get_parent() != target:
		enemy.reparent(target)
	(enemy as Node2D).global_position = _get_spawn_position()
	enemy.reset()
	enemy._tower_ref = _tower_node
	_active_enemies.append(enemy)
	_spawned_count += 1
	if _spawned_count >= _total_to_spawn:
		_trickle_timer.stop()


func _get_spawn_position() -> Vector2:
	# Uniform random point on the rectangle perimeter
	var hw := _ARENA_HALF_W
	var hh := _ARENA_HALF_H
	var cx := _ARENA_CENTER.x
	var cy := _ARENA_CENTER.y
	var t := randf() * (hw * 4.0 + hh * 4.0)

	if t < hw * 2.0:                          # top edge (left → right)
		return Vector2(cx - hw + t, cy - hh)
	t -= hw * 2.0
	if t < hh * 2.0:                          # right edge (top → bottom)
		return Vector2(cx + hw, cy - hh + t)
	t -= hh * 2.0
	if t < hw * 2.0:                          # bottom edge (right → left)
		return Vector2(cx + hw - t, cy + hh)
	t -= hw * 2.0
	return Vector2(cx - hw, cy + hh - t)      # left edge (bottom → top)


func _on_trickle_timer_timeout() -> void:
	_spawn_enemy()


func _on_enemy_died(enemy: Node, _position: Vector2) -> void:
	_active_enemies.erase(enemy)
	_total_killed += 1
	if _total_killed >= _total_to_spawn:
		_trickle_timer.stop()
		EventBus.wave_cleared.emit(GameState.wave_number)

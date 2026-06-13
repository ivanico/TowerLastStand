extends Node

var _pools: Dictionary   # { resource_path: Array[Node] }
var _pool_root: Node2D


func _ready() -> void:
	_pool_root = Node2D.new()
	_pool_root.name = "PoolRoot"
	add_child(_pool_root)


func acquire(scene: PackedScene) -> Node:
	var key := scene.resource_path
	if not _pools.has(key):
		_pools[key] = []
	var pool: Array = _pools[key]
	var node: Node
	if pool.is_empty():
		node = scene.instantiate()
		_pool_root.add_child(node)
	else:
		node = pool.pop_back()
	_set_node_active(node, true)
	return node


func release(node: Node) -> void:
	var key := node.scene_file_path
	if not _pools.has(key):
		_pools[key] = []
	_set_node_active(node, false)
	_pools[key].append(node)


func preload_pool(scene: PackedScene, count: int) -> void:
	var key := scene.resource_path
	if not _pools.has(key):
		_pools[key] = []
	for i in count:
		var node: Node = scene.instantiate()
		_pool_root.add_child(node)
		_set_node_active(node, false)
		_pools[key].append(node)


func release_all(scene: PackedScene) -> void:
	var key := scene.resource_path
	if not _pools.has(key):
		return
	for node in _pool_root.get_children():
		if node.scene_file_path == key and _set_node_active(node, false):
			if not _pools[key].has(node):
				_pools[key].append(node)


func _set_node_active(node: Node, active: bool) -> bool:
	if node is CanvasItem:
		node.visible = active
	for child in node.find_children("*", "CollisionShape2D", true, false):
		child.set_deferred("disabled", not active)
	for child in node.find_children("*", "CollisionPolygon2D", true, false):
		child.set_deferred("disabled", not active)
	return true

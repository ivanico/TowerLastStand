extends Node

var _sfx_pool: Array[AudioStreamPlayer]
var _music_player: AudioStreamPlayer
var _music_target: AudioStream


func _ready() -> void:
	for i in 12:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_pool.append(player)
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	var player := _get_idle_sfx_player()
	player.stream    = stream
	player.volume_db = volume_db
	player.play()


func play_music(stream: AudioStream, _crossfade: bool = true) -> void:
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func set_sfx_volume(db: float) -> void:
	for player in _sfx_pool:
		player.volume_db = db


func set_music_volume(db: float) -> void:
	_music_player.volume_db = db


func _get_idle_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_pool:
		if not player.playing:
			return player
	return _sfx_pool[0]  # all busy — reuse oldest


func _crossfade(_from: AudioStreamPlayer, _to_stream: AudioStream) -> void:
	pass  # Full implementation in Epic 07

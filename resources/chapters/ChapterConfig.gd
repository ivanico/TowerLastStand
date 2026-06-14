class_name ChapterConfig
extends Resource

@export var chapter_id: int
@export var chapter_name: String
@export var modifier_description: String
@export var background_scene: PackedScene
@export var music_track: AudioStream
@export var waves: Array[WaveConfig]
@export var material_type: int              # Constants.MaterialType
@export var chapter_mat_drop_range: Vector2i

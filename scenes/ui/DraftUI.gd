class_name DraftUI
extends CanvasLayer

const _CARD_SCENE: PackedScene = preload("res://scenes/ui/DraftCard.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	hide()
	EventBus.draft_opened.connect(_on_draft_opened)
	EventBus.draft_closed.connect(_on_draft_closed)


func _on_draft_opened() -> void:
	for child in $Panel/VBox/CardRow.get_children():
		child.queue_free()
	for card_data in DraftManager._current_draft_cards:
		var card := _CARD_SCENE.instantiate() as DraftCard
		$Panel/VBox/CardRow.add_child(card)
		card.setup(card_data)
		card.card_selected.connect(_on_card_selected)
	show()


func _on_draft_closed() -> void:
	hide()


func _on_card_selected(card_data: Resource) -> void:
	DraftManager.select_card(card_data)

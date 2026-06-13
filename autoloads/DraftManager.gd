extends Node

var _card_pool: Array
var _taken_cards: Array


func open_draft() -> void:
	print("open_draft called")
	EventBus.draft_opened.emit()  # Full implementation in Epic 03


func select_card(_card: Resource) -> void:
	EventBus.draft_closed.emit()  # Full implementation in Epic 03

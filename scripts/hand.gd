extends Node2D

@export var cards: Array[Node2D] = []
@export var cards_positions: Array[Vector2]
@export var cards_rotations: Array[int]
@export var start_turn_position: Node2D
@export var end_turn_position: Node2D


func deal_card(card_index: int):
	var slot_position = cards_positions[card_index]
	var slot_rotation = cards_rotations[card_index]
	cards[card_index].slot_position = slot_position
	cards[card_index].slot_rotation = slot_rotation
	await set_card_position_and_rotation(cards[card_index], slot_position, slot_rotation)
	cards[card_index].is_draggable = true


func set_card_position_and_rotation(card: Node2D, position: Vector2, rotation: int):
	await get_tree().create_timer(0.1).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", position, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rotation_degrees", rotation, 0.1).set_ease(Tween.EASE_OUT)


func start_turn():
	for card in cards:
		card.position = start_turn_position.position
	for card_index in len(cards):
		await deal_card(card_index)


func end_turn():
	for card_index in len(cards):
		await set_card_position_and_rotation(cards[card_index], end_turn_position.position, 0)


func _on_button_pressed() -> void:
	start_turn()
	await get_tree().create_timer(2).timeout
	#end_turn()

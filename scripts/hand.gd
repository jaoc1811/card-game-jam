extends Node2D

var cards: Array[Node]
@export var cards_positions: Array[Vector2]
@export var cards_rotations: Array[int]

# Called when the node enters the scene tree for the first time.


func set_position_and_rotation(card_index: int):
	await get_tree().create_timer(0.1).timeout
	var tween = get_tree().create_tween()
	var slot_position = cards_positions[card_index]
	var slot_rotation = cards_rotations[card_index]
	cards[card_index].slot_position = slot_position
	cards[card_index].slot_rotation = slot_rotation
	tween.tween_property(cards[card_index], "position", slot_position, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(cards[card_index], "rotation_degrees", slot_rotation, 0.1).set_ease(Tween.EASE_OUT)
	cards[card_index].is_draggable = true

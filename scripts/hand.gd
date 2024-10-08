extends Node2D

@onready var game_manager: Node = %GameManager
@export var cards: Array[Node2D] = []
@export var cards_positions: Array[Vector2]
@export var cards_rotations: Array[int]

func deal_card(card_index: int):
	var slot_position = cards_positions[card_index]
	var slot_rotation = cards_rotations[card_index]
	cards[card_index].slot_position = slot_position
	cards[card_index].slot_rotation = slot_rotation
	await set_card_position_and_rotation(cards[card_index], slot_position, slot_rotation)


func set_card_position_and_rotation(card: Node2D, position: Vector2, rotation: int):
	game_manager.deal_card_sfx.play()
	await get_tree().create_timer(0.1).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", position, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rotation_degrees", rotation, 0.1).set_ease(Tween.EASE_OUT)


func start_turn():
	for card in cards:
		card.position = game_manager.start_turn_position.position
	for card_index in len(cards):
		await deal_card(card_index)


func end_turn(card_played_index: int):
	var card_played = cards.pop_at(card_played_index)
	var card_location = card_played.global_position
	remove_child(card_played)
	game_manager.played_card_nodes.add_child(card_played)
	card_played.global_position = card_location
	card_played.is_draggable = false
	card_played.get_node("Card back").show()
	card_played.get_node("Card front").hide()
	# Animation
	for card_index in len(cards):
		await set_card_position_and_rotation(cards[card_index], game_manager.end_turn_position.position, 0)

	return card_played
#
#func _on_button_pressed() -> void:
	#start_turn()
	#await get_tree().create_timer(2).timeout
	#end_turn()

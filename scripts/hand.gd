extends Node2D

var cards: Array[Node]
@export var cards_positions: Array[Vector2]
@export var cards_rotations: Array[int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cards = get_children()
	for i in len(cards):
		await get_tree().create_timer(0.1).timeout
		set_position_and_rotation(i)


func set_position_and_rotation(card_index: int):
	var tween = get_tree().create_tween()
	tween.tween_property(cards[card_index], "position", cards_positions[card_index], 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(cards[card_index], "rotation_degrees", cards_rotations[card_index], 0.1).set_ease(Tween.EASE_OUT)
	cards[card_index].is_draggable = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

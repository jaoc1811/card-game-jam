extends Node2D

var cards
@export var horizontal_size = 150

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cards = get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for card in cards:
		print(card)

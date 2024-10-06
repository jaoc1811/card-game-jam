extends Node2D

@onready var hand_sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_hand(start: int, end: int):
	var tween = get_tree().create_tween()
	var duration: float = abs(end-start)/30
	var rotation: float = end * 360 / 720
	print(start, end, rotation, duration)
	tween.tween_property(self, "rotation_degrees", rotation, duration)

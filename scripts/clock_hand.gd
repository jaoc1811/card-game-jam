extends Node2D

@onready var hand_sprite: Sprite2D = $Sprite2D
#@export var time: int = 0 :
	#get:
		#return time
	#set(value):
		#if value != time:
			#move_hand(time, value)
		#time = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func move_hand(start: int, end: int):
	var tween = get_tree().create_tween()
	var duration = abs(end-start)
	var rotation = end * (360/12)
	tween.tween_property(self, "rotation_degrees", rotation, duration)

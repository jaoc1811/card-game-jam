extends Node2D

var is_hovering = false
var is_dragging = false
var offset: Vector2

func _process(delta):
	if is_hovering:
		scale = Vector2(1.05,1.05)
	else:
		scale = Vector2(1,1)
	if is_dragging:
		position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	is_dragging = true
	offset = get_global_mouse_position() - position

func _on_button_button_up() -> void:
	is_dragging = false
	position = Vector2(0,0)

func _on_button_mouse_entered() -> void:
	is_hovering = true

func _on_button_mouse_exited() -> void:
	is_hovering = false

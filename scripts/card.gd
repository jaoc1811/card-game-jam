class_name Card
extends Node2D

@onready var game_manager: Node = %GameManager

var is_hovering = false
var is_dragging = false
var is_draggable = false
var is_inside_deck = false
var offset: Vector2
var initial_position: Vector2
var initial_rotation: int
var deck_ref

func _process(delta):
	if is_hovering:
		scale = Vector2(1.05,1.05)
	else:
		scale = Vector2(1,1)
	if is_dragging:
		position = get_global_mouse_position() - offset

func _on_button_button_down() -> void:
	if is_draggable:
		is_dragging = true
		offset = get_global_mouse_position() - position
		initial_position = position
		initial_rotation = rotation_degrees
		var tween = get_tree().create_tween()
		tween.tween_property(self,"rotation_degrees", 0, 0.1).set_ease(Tween.EASE_OUT)

func _on_button_button_up() -> void:
	if is_dragging:
		is_dragging = false
		var tween = get_tree().create_tween()
		if is_inside_deck:
			tween.tween_property(self,"global_position", deck_ref.position, 0.1).set_ease(Tween.EASE_OUT)
		else:
			tween.tween_property(self,"position", initial_position, 0.1).set_ease(Tween.EASE_OUT)
			tween.tween_property(self,"rotation_degrees", initial_rotation, 0.1).set_ease(Tween.EASE_OUT)
	
func _on_button_mouse_entered() -> void:
	if is_draggable:
		is_hovering = true

func _on_button_mouse_exited() -> void:
	is_hovering = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("deck"):
		is_inside_deck = true
		deck_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("deck"):
		is_inside_deck = false

func play(player_position: int):
	pass

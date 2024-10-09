class_name Card
extends Node2D

@onready var shadow: Polygon2D = $Shadow

@export var is_hovering = false
@export var is_dragging = false
@export var is_draggable = false
var is_inside_playable_area = false
var offset: Vector2
var slot_position: Vector2
var slot_rotation: int
var playable_area
var type: String


func _process(delta):
	if is_hovering:
		scale = Vector2(1.05, 1.05)
	else:
		scale = Vector2(1, 1)
	if is_dragging:
		position = get_global_mouse_position() - offset


func _on_button_button_down() -> void:
	if is_draggable:
		GameManager.take_card_sfx.play()
		is_dragging = true
		GameManager.show_play_button = false
		offset = get_global_mouse_position() - position
		var tween = get_tree().create_tween()
		self.z_index = 1
		tween.tween_property(shadow, "position", Vector2(0, 4), 0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation_degrees", 0, 0.1).set_ease(Tween.EASE_OUT)


func _on_button_button_up() -> void:
	if is_dragging:
		GameManager.take_card_sfx.play()
		is_dragging = false
		var tween = get_tree().create_tween()
		self.z_index = 0
		tween.tween_property(shadow, "position", Vector2(0, 0), 0.1).set_ease(Tween.EASE_OUT)
		if is_inside_playable_area and playable_area.get_meta("card", null):
			tween.tween_property(self, "global_position", playable_area.position, 0.1).set_ease(Tween.EASE_OUT)
			GameManager.show_play_button = true
			GameManager.selected_card_index = get_parent().cards.find(self)
		else:
			if playable_area and playable_area.get_meta("card", null) == null:
				GameManager.show_play_button = false
			else:
				GameManager.show_play_button = true
			tween.tween_property(self, "position", slot_position, 0.1).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rotation_degrees", slot_rotation, 0.1).set_ease(Tween.EASE_OUT)


func _on_button_mouse_entered() -> void:
	is_hovering = true
	if get_node("Card front").is_visible():
		GameManager.hovering_card = self


func _on_button_mouse_exited() -> void:
	GameManager.hovering_card = null
	is_hovering = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("playable_area") and body.get_meta("card", null) == null:
		body.set_meta("card", self)
		is_inside_playable_area = true
		playable_area = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("playable_area"):
		if body.get_meta("card", null) == self:
			body.set_meta("card", null)
		is_inside_playable_area = false


func play(player_position: int):
	pass

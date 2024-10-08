extends Control

func _on_2_players_pressed() -> void:
	print('xD1')
	pass # Replace with function body.


func _on_3_players_pressed() -> void:
	print('xD2')
	pass # Replace with function body.


func _on_4_players_pressed() -> void:
	print('xD3')

	pass # Replace with function body.


func _on_back_pressed() -> void:
	print('xD4')
	get_tree().change_scene_to_file('res://scenes/menu.tscn')

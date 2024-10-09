extends Control

func _on_2_players_pressed() -> void:
	GameManager.num_of_players = 2
	get_tree().change_scene_to_file('res://scenes/game.tscn')

func _on_3_players_pressed() -> void:
	GameManager.num_of_players = 3
	get_tree().change_scene_to_file('res://scenes/game.tscn')

func _on_4_players_pressed() -> void:
	GameManager.num_of_players = 4
	get_tree().change_scene_to_file('res://scenes/game.tscn')

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/menu.tscn')

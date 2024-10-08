extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/player_selection.tscn')

func _on_sound_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/change_sound_menu.tscn')
	
func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/how_to_play.tscn')

func _on_quit_pressed() -> void:
	get_tree().quit()
	

class_name time_investment
extends Card


func play(player_position: int) -> void:
	## Add 15 hours to passive clock
	game_manager.players[player_position].passive_clock += 15

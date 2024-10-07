class_name time_loan
extends Card


func play(player_position: int) -> void:
	## Add 15 hours to passive clock
	game_manager.players[player_position].passive_clock -= 15
	game_manager.players[player_position].round_points += 240 * game_manager.reverse_flow

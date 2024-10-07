class_name catch_up
extends Card


func play(player_position: int) -> void:
	## If the player's score is lower or equal than all other players, add 3 hours
	var score = game_manager.players[player_position].clock
	var lowest = true
	for player in game_manager.players:
		if player.clock < score:
			lowest = false
			break
	if lowest:
		game_manager.players[player_position].round_points += 180 * game_manager.reverse_flow

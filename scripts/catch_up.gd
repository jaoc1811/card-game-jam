class_name catch_up
extends Card


func play(player_position: int):
	## If the player's score is lower or equal than all other players, add 3 hours
	var score = game_manager.players[player_position].clock
	var lowest = true
	for player in game_manager.players:
		if player.clock < score:
			lowest = false
			break
	var score_dict = {
		player_position: {
			"round_points": 0 # To show animation when no points are added
		}
	}
	if lowest:
		#game_manager.players[player_position].round_points += 180 * game_manager.reverse_flow
		score[player_position] = {
			"round_points": 180
		}
	return score

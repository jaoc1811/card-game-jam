class_name robin_hood
extends Card

func play(player_position: int):
	## Add +2 hours to player and -2 hours to player with more hours
	## If there is more than one such player, random pick
	## Cannot choose same player
	var max_hours_players = []
	var max_hours = 0

	# Get max hours
	for player in game_manager.players:
		if player.clock > max_hours:
			max_hours = player.clock

	# Get players with max hours
	for player_pos in len(game_manager.players):
		if (game_manager.players[player_pos].clock == max_hours 
			and player_pos != player_position):
			max_hours_players.append(player_pos)

	# Get random player
	#max_hours_players.pick_random().round_points -= 120 * game_manager.reverse_flow
	#game_manager.players[player_position].round_points += 120 * game_manager.reverse_flow
	var score = {
		player_position: {
			"round_points": 0 # To show animation when no points are added
		}
	}
	if len(max_hours_players) != 0:
		score[max_hours_players.pick_random()] = {
			"round_points": -120
		}
		score[player_position] = {
			"round_points": 120
		}
	return score

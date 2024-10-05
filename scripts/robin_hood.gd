extends Card

func play(player_position: int):
	## Add +2 hours to player and -2 hours to player with more hours
	## If there is more than one such player, random pick
	var max_hours_players = []
	var max_hours = 0

	# Get max hours
	for player in game_manager.players:
		if player.clock > max_hours:
			max_hours = player.clock

	# Get players with max hours
	for player in game_manager.players:
		if player.clock == max_hours:
			max_hours_players.append(player)

	# Get random player
	max_hours_players.pick_random().round_points -= 120 * game_manager.reverse_flow
	game_manager.players[player_position].round_points += 120 * game_manager.reverse_flow

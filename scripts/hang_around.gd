class_name hang_around
extends Card

func play(player_position: int):
	## Add one hour to player
	return {
		player_position: {
			"round_points" = 60
		}
	}
	#game_manager.players[player_position].round_points += 60 * game_manager.reverse_flow

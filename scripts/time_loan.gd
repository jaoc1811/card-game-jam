class_name time_loan
extends Card


func play(player_position: int):
	## Substract 15 minutes from passive clock and add 4 hours to round points
	
	if GameManager.players[player_position].passive_clock <= 15:
		return {
			player_position: {
				"passive_clock": 0,
				"round_points": 0
			}
		}
	return {
		player_position: {
			"passive_clock": -15,
			"round_points": 240
		}
	}

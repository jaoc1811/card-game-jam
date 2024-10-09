class_name time_investment
extends Card


func play(player_position: int):
	## Add 15 minutes to passive clock
	return {
		player_position: {
			"passive_clock": 15
		}
	}

class_name reverse_flow
extends Card

func play(player_position: int):
	## This round, reverse all scores
	GameManager.reverse_flow *= -1
	for player in GameManager.players:
		player.round_points *= GameManager.reverse_flow
	
	return {}

class_name reverse_flow
extends Card

func play(player_position: int):
	## This round, reverse all scores
	game_manager.reverse_flow *= -1
	for player in game_manager.players:
		player.round_points *= game_manager.reverse_flow

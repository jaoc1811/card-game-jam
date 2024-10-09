class_name feeling_lucky
extends Card

func play(player_position: int):
	var heads = 1
	var coin_value = randi() % 2 # 0 or 1
	var hour_value = 60
	var gambling_hours_amount = 3
	var points = hour_value * gambling_hours_amount
	var punishment_multiplier = -1

	if coin_value == heads:
		await GameManager.coin_heads_animation()
	else:
		await GameManager.coin_tails_animation()

	return {
		player_position: {
			"round_points" = points if heads == coin_value else (points * punishment_multiplier)
		}
	}

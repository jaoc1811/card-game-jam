class_name feeling_lucky
extends Card

# TODO: Move to gamemanager
@onready var win: AnimatedSprite2D = $"../CoinFlip/Win"
@onready var lose: AnimatedSprite2D = $"../CoinFlip/Lose"

func play(player_position: int):
	var heads = 1
	var coin_value = randi() % 2 # 0 or 1
	var hour_value = 60
	var gambling_hours_amount = 3
	var points = hour_value * gambling_hours_amount
	var punishment_multiplier = -1

	# TODO: Move to gamemanager
	if coin_value == heads:
		win.show()
		win.play()
		var duration = win.sprite_frames.get_frame_count("CoinFlipWin")/win.sprite_frames.get_animation_speed("CoinFlipWin")
		print(duration)
		await get_tree().create_timer(duration + 1,5).timeout
		win.hide()
	else:
		lose.show()
		lose.play()
		var duration = win.sprite_frames.get_frame_count("CoinFlipLose")/win.sprite_frames.get_animation_speed("CoinFlipLose")
		print(duration)
		await get_tree().create_timer(duration + 1,5).timeout
		win.hide()
	return {
		player_position: {
			"round_points" =  points if heads == coin_value else (points * punishment_multiplier)
		}
	}

func _ready() -> void:
	await play(0)
	print("Done")

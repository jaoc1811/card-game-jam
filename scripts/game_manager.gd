extends Node

# Players
@export var num_of_players: int
@export var players: Array[Node]
var player_detail = []  # Array of dicts with ref to player and card played this round
var current_player: int = 0  # NUMERO QUE REPRESENTA EL JUGADOR (ES EL INDICE CORRESPONDIENTE EN EL ARREGLO PLAYERS)

# Gameloop
var ready_to_start_game: bool = false
var game_started: bool = false
var new_turn: bool = true
var show_play_button: bool = false
@onready var play_button: Button = $"Play Button"
var show_next_player_button: bool = false
@onready var next_player_button: Button = $"Next Player Button"
var selected_card_index: int
var hovering_card: Node2D
var show_next_round_button: bool = false
@onready var next_round_button: Button = $"Next Round Button"
@onready var info_card: Node2D = $InfoCard

# Win conditions
@export var target_points = 720
var win = false

# Deck
@export var deck_type = {}  # Dict with ref to card type and amount of cards per type
@export var deck_node: Node2D
var deck: Array[String]  # Card types, initialized when drawn from deck
var played_cards: Array[String] = []  # Played card types (for current round)
var discard_pile: Array[String] = []  # Discarded card types
@export var start_turn_position: Node2D
@export var end_turn_position: Node2D

# Cards
@export var cards_per_player = 4
var base_card = load("res://scenes/card.tscn")
var card_type_scripts = {
	"catch_up": load("res://scripts/catch_up.gd"),
	"feeling_lucky": load("res://scripts/feeling_lucky.gd"),
	"hang_around": load("res://scripts/hang_around.gd"),
	"reverse_flow": load("res://scripts/reverse_flow.gd"),
	"robin_hood": load("res://scripts/robin_hood.gd"),
	"time_investment": load("res://scripts/time_investment.gd"),
	"time_loan": load("res://scripts/time_loan.gd")
}
var card_type_sprites = {
	"catch_up": load("res://sprites/cards/catch_up_card.png"),
	"feeling_lucky": load("res://sprites/cards/feeling_lucky_card.png"),
	"hang_around": load("res://sprites/cards/hang_around_card.png"),
	"reverse_flow": load("res://sprites/cards/reverse_flow_card.png"),
	"robin_hood": load("res://sprites/cards/robin_hood_card.png"),
	"time_investment": load("res://sprites/cards/time_investment_card.png"),
	"time_loan": load("res://sprites/cards/time_loan_card.png")
}
var playable_areas: Array[Node2D] = []
@onready var played_card_nodes: Node = $"Played Card Nodes"

# Audio Manager
@onready var deal_card_sfx: AudioStreamPlayer2D = $DealCardSFX
@onready var take_card_sfx: AudioStreamPlayer2D = $TakeCardSFX
@onready var button_sfx: AudioStreamPlayer2D = $ButtonSFX
@onready var add_time_sfx: AudioStreamPlayer2D = $AddTimeSFX
@onready var add_passive_sfx: AudioStreamPlayer2D = $AddPassiveSFX

# Either 1 or -1
@export var reverse_flow: int = 1:
	set(new_value):
		reverse_flow = new_value
		# TODO: update UI
		

func start_game() -> void:
	players = get_tree().get_nodes_in_group("player")
	deck_node = get_tree().get_first_node_in_group("deck")
	start_turn_position = get_tree().get_first_node_in_group("start_turn_position")
	end_turn_position = get_tree().get_first_node_in_group("end_turn_position")
	player_detail = []
	playable_areas = []

	for i in len(players)-num_of_players:
		var player = players.pop_back()
		player.queue_free()
	for i in len(players):
		(
			player_detail
			. append(
				{
					"player": players[i],
					"card_played": null
					# TODO: play history
				}
			)
		)
		playable_areas.append(players[i].get_node("PlayableArea"))

	# Create & shuffle deck
	create_deck()
	game_started = true
	win = false
	current_player = 0
	new_turn = true
	self.get_node("InfoCard").show()


func create_deck() -> void:
	for card_type in deck_type:
		for i in range(deck_type[card_type]):
			deck.append(card_type)
	# Shuffle deck
	deck.shuffle()


func deal_cards(player_position: int) -> void:
	var hand: Node2D = players[player_position].get_node("Hand")
	var next_card_type: String
	var next_card: Node2D
	var cards_in_hand = hand.get_child_count()
	var card_front_sprite: Sprite2D
	for card_index in range(cards_in_hand, cards_per_player):
		if len(deck) == 0:
			reshuffle_deck()

		next_card_type = deck.pop_front()
		next_card = base_card.instantiate()

		hand.add_child(next_card)
		hand.cards.append(next_card)

		# TODO: esto hay que arreglarlo con la nueva manera de buscar las cartas
		next_card.global_position = deck_node.position
		next_card.name = next_card_type
		# Set script and references lost when loading new script
		next_card.set_script(card_type_scripts[next_card_type])
		next_card.type = next_card_type
		next_card.get_node("Card back").hide()
		card_front_sprite = next_card.get_node("Card front")
		card_front_sprite.texture = card_type_sprites[next_card_type]
		card_front_sprite.show()
		next_card.playable_area = playable_areas[player_position]
		#next_card.game_manager = self
		next_card.shadow = next_card.get_node("Shadow")

		await hand.deal_card(card_index)


func reshuffle_deck() -> void:
	deck = discard_pile
	discard_pile = []
	# Shuffle deck
	deck.shuffle()


func start_turn(player: int):
	# Runs each turn
	var hand: Node2D = players[player].get_node("Hand")
	for card in hand.cards:
		card.is_draggable = false
	await hand.start_turn()
	await get_tree().create_timer(1).timeout
	await deal_cards(player)
	for card in hand.cards:
		card.is_draggable = true


func end_turn(player: int, card_played_index: int):
	var hand: Node2D = players[player].get_node("Hand")
	var card_played = await hand.end_turn(card_played_index)
	player_detail[player]["card_played"] = card_played
	# TODO: add to play history
	played_cards.append(card_played.get_script().get_global_name())
	show_play_button = false


func add_points(points):
	var passive_clock
	var round_points
	for player_position in points:
		passive_clock = points[player_position].get("passive_clock", null)
		round_points = points[player_position].get("round_points", null)
		if passive_clock != null:
			players[player_position].passive_clock += passive_clock
		if round_points != null:
			players[player_position].round_points += round_points * reverse_flow


func check_clocks():
	var winners = []
	for player_position in len(players):
		if players[player_position].clock >= target_points:
			winners.append("Player " + str(player_position + 1))
	if len(winners) > 0:
		win = true
		self.get_node("InfoCard").hide()
		for player in len(players):
			turn_off_playable_area(player)
			if is_instance_valid(player_detail[player]["card_played"]):
				player_detail[player]["card_played"].queue_free()
		var win_screen = get_tree().get_first_node_in_group("win_screen")
		var win_text = "Winners:\n" if len(winners) > 1 else "Winner:\n"
		win_text += ", ".join(winners)
		win_screen.get_node("Win text").text = win_text
		win_screen.show()


func end_round():
	# Play cards and add points in order
	var card_played
	var points
	for player in players:
		player.round_points_label.text = "+0h"
		player.round_points_label.show()

	for player_position in len(player_detail):
		card_played = player_detail[player_position]["card_played"]
		card_played.get_node("Card back").hide()
		card_played.get_node("Card front").show()
		points = await card_played.play(player_position)
		add_points(points)
		add_time_sfx.play()
		await get_tree().create_timer(2).timeout
		# Send card to discard pile
		discard_pile.append(card_played.get_script().get_global_name())

	played_cards = []

	# Add passive points
	for player in players:
		player.round_points += player.passive_clock * reverse_flow
		add_passive_sfx.play()
	await get_tree().create_timer(3).timeout

	# Update clock points
	for player in players:
		player.clock += player.round_points

	# Check if there are winners
	check_clocks()

	if not win:
		show_next_round_button = true
		new_turn = false

func start_round():
	# Return to initial values
	for player in player_detail:
		# Delete card node
		if is_instance_valid(player["card_played"]):
			player["card_played"].queue_free()
		player["card_played"] = null
		player["player"].round_points = 0
		player["player"].round_points_label.hide()

	if reverse_flow != 1:  # To prevent UI update twice
		reverse_flow = 1


func turn_off_playable_area(player: int):
	players[current_player].get_node("PlayableArea").hide()
	players[current_player].get_node("PlayableArea").process_mode = Node.PROCESS_MODE_DISABLED


func turn_on_playable_area(player: int):
	players[current_player].get_node("PlayableArea").show()
	players[current_player].get_node("PlayableArea").process_mode = Node.PROCESS_MODE_INHERIT


func next_player():
	new_turn = true
	turn_off_playable_area(current_player)
	current_player = (current_player + 1) % len(players)
	turn_on_playable_area(current_player)


func _on_button_pressed() -> void:
	button_sfx.play()
	await end_turn(current_player, selected_card_index)
	#new_turn = true
	show_play_button = false
	show_next_player_button = true
	if current_player == len(players) - 1:
		next_player_button.text = "End Round"
		#await end_round()
	else:
		next_player_button.text = "Next Player"
	#if not win:
		#next_player()


func _on_next_player_button_pressed() -> void:
	button_sfx.play()
	#await end_turn(current_player, selected_card_index)
	show_next_player_button = false
	if current_player == len(players) - 1:
		turn_off_playable_area(current_player)
		await end_round()
	else:
		if not win:
			next_player()


func _on_next_round_button_pressed() -> void:
	button_sfx.play()
	new_turn = true
	show_next_round_button = false
	next_player()
	start_round()


func move_info_card_up(hovering_card_type) -> void:
	var info_card_sprite = info_card.get_node("Sprite")
	info_card_sprite.texture = card_type_sprites[hovering_card_type]
	var tween = get_tree().create_tween()
	tween.tween_property(info_card, "position", Vector2(info_card.position.x, 20), 0.1).set_ease(Tween.EASE_OUT)


func move_info_card_down() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(info_card, "position", Vector2(info_card.position.x, 110), 0.1).set_ease(Tween.EASE_OUT)


func coin_heads_animation():
	var coin_flip_win: AnimatedSprite2D = get_tree().get_first_node_in_group("coin_flip_win")
	coin_flip_win.show()
	coin_flip_win.play()
	var duration = coin_flip_win.sprite_frames.get_frame_count("CoinFlipWin")/coin_flip_win.sprite_frames.get_animation_speed("CoinFlipWin")
	await get_tree().create_timer(duration + 1,5).timeout
	coin_flip_win.hide()


func coin_tails_animation():
	var coin_flip_lose: AnimatedSprite2D = get_tree().get_first_node_in_group("coin_flip_lose")
	coin_flip_lose.show()
	coin_flip_lose.play()
	var duration = coin_flip_lose.sprite_frames.get_frame_count("CoinFlipLose")/coin_flip_lose.sprite_frames.get_animation_speed("CoinFlipLose")
	await get_tree().create_timer(duration + 1,5).timeout
	coin_flip_lose.hide()


func _process(delta: float) -> void:
	if ready_to_start_game:
		ready_to_start_game = false
		start_game()
	
	if !game_started:
		return
		
	if not win:
		if new_turn:
			new_turn = false
			await start_turn(current_player)

	if show_play_button:
		play_button.show()
		play_button.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		play_button.hide()
		play_button.process_mode = Node.PROCESS_MODE_DISABLED
	
	if show_next_player_button:
		next_player_button.show()
		next_player_button.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		next_player_button.hide()
		next_player_button.process_mode = Node.PROCESS_MODE_DISABLED
	
	if show_next_round_button:
		next_round_button.show()
		next_round_button.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		next_round_button.hide()
		next_round_button.process_mode = Node.PROCESS_MODE_DISABLED
		
	if current_player == 0 or current_player == 1:
		info_card.position = Vector2(60, info_card.position.y)
	elif  current_player == 2 or current_player == 3:
		info_card.position = Vector2(-60, info_card.position.y)
	
	if hovering_card != null:
		move_info_card_up(hovering_card.type)
	else:
		move_info_card_down()

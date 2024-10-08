extends Node

# Players
@export var players: Array[Node]
var player_detail = []  # Array of dicts with ref to player and card played this round
var current_player: int = 0  # NUMERO QUE REPRESENTA EL JUGADOR (ES EL INDICE CORRESPONDIENTE EN EL ARREGLO PLAYERS)
var can_play: bool = false

# Gameloop
var new_turn: bool = true
var show_play_button: bool = false
@onready var play_button: Button = $"Play Button"
var show_next_player_button: bool = false
@onready var next_player_button: Button = $"Next Player Button"
var selected_card_index: int
var show_next_round_button: bool = false
@onready var next_round_button: Button = $"Next Round Button"

# Win conditions
@export var target_points = 720
var win = false
@onready var win_screen: Label = $"Win screen"

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
var base_card = load("res://Scenes/card.tscn")
var card_type_scripts = {
	"catch_up": load("res://scripts/catch_up.gd"),
	"feeling_lucky": load("res://scripts/feeling_lucky.gd"),
	"hang_around": load("res://scripts/hang_around.gd"),
	"reverse_flow": load("res://scripts/reverse_flow.gd"),
	"robin_hood": load("res://scripts/robin_hood.gd"),
	"time_investment": load("res://scripts/time_investment.gd"),
	"time_loan": load("res://scripts/time_loan.gd")
}
var playable_areas: Array[Node2D] = []

# Audio Manager
@onready var deal_card_sfx: AudioStreamPlayer2D = $DealCardSFX

# Either 1 or -1
@export var reverse_flow: int = 1:
	set(new_value):
		reverse_flow = new_value
		# TODO: update UI
		print("reverse flow ", reverse_flow)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		next_card.playable_area = playable_areas[player_position]
		next_card.game_manager = self
		next_card.shadow = next_card.get_node("Shadow")

		await hand.deal_card(card_index)


func reshuffle_deck() -> void:
	print("Reshuffling deck: \n", deck, "\nDiscard pile: \n", discard_pile)
	deck = discard_pile
	discard_pile = []
	# Shuffle deck
	deck.shuffle()
	print("Final deck: \n", deck, "\nDiscard pile: \n", discard_pile)


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
		if passive_clock:
			players[player_position].passive_clock += passive_clock
		if round_points:
			players[player_position].round_points += round_points * reverse_flow


func check_clocks():
	var winners = []
	for player_position in len(players):
		if players[player_position].clock >= target_points:
			winners.append("Player " + str(player_position + 1))
	if len(winners) > 0:
		win = true
		for player in len(players):
			turn_off_playable_area(player)
		win_screen.text = "Winners:\n" if len(winners) > 1 else "Winner:\n"
		win_screen.text += ", ".join(winners)
		win_screen.show()
		# TODO: show back to menu button that reloads scene


func end_round():
	# Play cards and add points in order
	var card_played
	var points
	for player_position in len(player_detail):
		# TODO: await animations for each card played
		card_played = player_detail[player_position]["card_played"]
		points = card_played.play(player_position)
		add_points(points)
		# Send card to discard pile
		discard_pile.append(card_played.get_script().get_global_name())

	played_cards = []

	# Add passive_clock and update clock points
	for player in players:
		player.round_points += player.passive_clock * reverse_flow
		player.round_points_label.show()
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
	turn_off_playable_area(current_player)
	current_player = (current_player + 1) % len(players)
	turn_on_playable_area(current_player)


func _on_button_pressed() -> void:
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
	#await end_turn(current_player, selected_card_index)
	new_turn = true
	show_next_player_button = false
	if current_player == len(players) - 1:
		await end_round()
	if not win:
		next_player()


func _on_next_round_button_pressed() -> void:
	new_turn = true
	show_next_round_button = false
	start_round()


func _process(delta: float) -> void:
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
		

# TEST
#var run_once = true
#func _process(delta: float) -> void:
	#if run_once:
		#run_once = false
		#print("Initial deck: ", deck)
		#var round = 0
		#while win == false:
			#for player_position in len(players):
				#await start_turn(player_position)
				#await get_tree().create_timer(1.5).timeout
				#await end_turn(player_position, 0)
				#await get_tree().create_timer(1.5).timeout
				#print("Played cards this round: ", played_cards)
			#await end_round()
			#print("Discarded cards this round: ", discard_pile)
			#print("Deck before end round: ", deck)
			#print("END ROUND ", round)
			#round += 1
			#await get_tree().create_timer(2).timeout
		#print()

extends Node

# Player
@export var players: Array[Node]
var player_detail = [] # Array of dicts with ref to player and card played this round

# Deck
@export var deck_type = {} # Dict with ref to card type and amount of cards per type
@export var deck_node : Node2D
var deck : Array[String] # Card types, initialized when drawn from deck
var played_cards : Array[String] = [] # Played card types (for current round)
var discard_pile : Array[String] = [] # Discarded card types

# Cards
@export var cards_per_player = 4
var base_card = load("res://Scenes/card.tscn")
var card_type_scripts = {
	"hang_around": load("res://scripts/hang_around.gd"),
	"reverse_flow": load("res://scripts/reverse_flow.gd"),
	"robin_hood": load("res://scripts/robin_hood.gd")
}


# Either 1 or -1
@export var reverse_flow : int = 1:
	set(new_value):
		reverse_flow = new_value
		# TODO: update UI
		print("reverse flow ", reverse_flow)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in len(players):
		player_detail.append({
			"player": players[i],
			"card_played": null
			# TODO: play history
		})

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
		next_card.global_position = deck_node.position
		next_card.name = next_card_type
		# Set script and references lost when loading new script
		next_card.set_script(card_type_scripts[next_card_type])
		next_card.game_manager = self
		next_card.shadow = next_card.get_node("Shadow")
		
		hand.cards.append(next_card)
		await hand.deal_card(card_index)

func reshuffle_deck() -> void:
	print("Reshuffling deck: \n", deck, "\nDiscard pile: \n", discard_pile)
	deck = discard_pile
	discard_pile = []
	# Shuffle deck
	deck.shuffle()
	print("Final deck: \n", deck, "\nDiscard pile: \n", discard_pile)

func start_turn(player: int):
	# Runs each turn except for the first round
	deal_cards(player)

func end_turn(player: int, card_played: Node):
	player_detail[player]["card_played"] = card_played
	# TODO: add to play history
	played_cards.append(card_played.get_script().get_global_name())
	# TODO: quitar carta de la mano, no eliminar del arbol

func end_round():
	# Play cards and add points in order
	var card_played
	for player_position in len(player_detail):
		# TODO: await animations for each card played
		card_played = player_detail[player_position]["card_played"]
		card_played.play(player_position)
		# Send card to discard pile
		discard_pile.append(card_played.get_script().get_global_name())

	played_cards = []

	# Add passive_clock and update clock points
	for player in players:
		player.round_points += player.passive_clock * reverse_flow
		player.clock += player.round_points

	# Return to initial values
	for player in player_detail:
		player["card_played"] = null
		player["player"].round_points = 0

	if reverse_flow != 1: # To prevent UI update twice
		reverse_flow = 1

# TEST
#var run_once = true
#func _process(delta: float) -> void:
	#if run_once:
		#run_once = false
		#var rounds = 2
		#print("Initial deck: ", deck)
		## Deal cards
		#await deal_cards(0)
		#await deal_cards(1)
		#print("Deck after first deal: ", deck)
		##await get_tree().create_timer(1).timeout
		#var hand
		#var next_card
		#var played_cards_nodes
		#for round in rounds:
			#played_cards_nodes = []
			#for player_position in len(players):
				#print("Player ", player_position," playing... ")
				#start_turn(player_position)
				#hand = players[player_position].get_node("Hand")
				#hand.cards.pop_front()
				#print("Player ", player_position," hand: ", hand.get_children())
				#next_card = hand.get_child(0) # First card for testing
				#hand.remove_child(next_card)
				#print("Player ", player_position," playing: ", next_card.name)
				#end_turn(player_position, next_card)
				#played_cards_nodes.append(next_card)
				##print("Player ", player_position," hand at the end of turn: ", hand.get_children())
				##await get_tree().create_timer(1).timeout
			#print("Played cards this round: ", played_cards)
			#end_round()
			#print("Discarded cards this round: ", discard_pile)
			#print("Deck before end round: ", deck)
			#print("END ROUND ", round)
			## Delete card for testing
			#for card in len(played_cards_nodes):
				#if is_instance_valid(played_cards_nodes[card]):
					#played_cards_nodes[card].queue_free()
			##await get_tree().create_timer(2).timeout
			#print()

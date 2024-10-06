extends Node

# Player
@export var players: Array[Node]
var player_detail = [] # Array of dicts with ref to player and card played this round

# Deck
@export var deck_type = {} # Dict with ref to card type and amount of cards per type
@export var deck_node : Node2D
var deck : Array[String] # Card types, initialized when drawn from deck
var discard_pile : Array[String] # Played card types

# Cards
@export var cards_per_player = 4
var base_card = load("res://Scenes/card.tscn")
var card_type_scripts = {
	"hang_around": load("res://scripts/hang_around.gd"),
	"reverse_flow": load("res://scripts/reverse_flow.gd"),
	"robin_hood": load("res://scripts/robin_hood.gd")
}

# TEST
#@onready var hang_around_card: Node2D = $"../Hang Around Card"
#@onready var reverse_flow_card: Node2D = $"../Reverse Flow Card"
#@onready var robin_hood_card: Node2D = $"../Robin Hood Card"
#var run_once = true

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

# TEST
#func _process(delta: float) -> void:
	#if run_once:
		#run_once = false
		## Deal cards
		#await deal_cards(0)
		#await get_tree().create_timer(2).timeout
		#await deal_cards(1)
		#await get_tree().create_timer(2).timeout
		## Round 1
		##print(player_detail)
		#end_turn(0, hang_around_card)
		#await get_tree().create_timer(1).timeout
		#end_turn(1, hang_around_card)
		#await get_tree().create_timer(1).timeout
		#print(player_detail)
		#end_round()
		##print(player_detail)
		#print("FIN RONDA 1")
		#await get_tree().create_timer(3).timeout
		#print()
#
		### Round 2
		##print(player_detail)
		#end_turn(0, hang_around_card)
		#await get_tree().create_timer(1).timeout
		#end_turn(1, robin_hood_card)
		#await get_tree().create_timer(1).timeout
		#print(player_detail)
		#end_round()
		##print(player_detail)
		#print("FIN RONDA 2")
		#print()
#
		## Round 3
		#print(player_detail)
		#end_turn(0, hang_around_card)
		#end_turn(1, reverse_flow_card)
		#print(player_detail)
		#end_round()
		#print(player_detail)
		#print("FIN RONDA 3")
		#print()
		#
		## Round 3
		#print(player_detail)
		#end_turn(0, reverse_flow_card)
		#end_turn(1, reverse_flow_card)
		#print(player_detail)
		#end_round()
		#print(player_detail)
		#print("FIN RONDA 4")
		#print()
		#
		## Round 4
		#print(player_detail)
		#end_turn(0, robin_hood_card)
		#end_turn(1, reverse_flow_card)
		#print(player_detail)
		#end_round()
		#print(player_detail)
		#print("FIN RONDA 5")

func end_turn(player: int, card_played: Node):
	player_detail[player]["card_played"] = card_played
	# TODO: add to play history
	discard_pile.append(card_played.get_script().get_global_name())

func end_round():
	# Play cards and add points in order
	for player_position in len(player_detail):
		# TODO: await animations
		player_detail[player_position]["card_played"].play(player_position)
		# TODO: add card played to discard_pile

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

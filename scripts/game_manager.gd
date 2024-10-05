extends Node

@export var players: Array[Node]
var player_detail = [] # Array of dicts with ref to player and card played this round

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

# TEST
#func _process(delta: float) -> void:
	#if run_once:
		#run_once = false
#
		## Round 1
		#print(player_detail)
		#end_turn(0, hang_around_card)
		#end_turn(1, hang_around_card)
		#print(player_detail)
		#end_round()
		#print(player_detail)
		#print("FIN RONDA 1")
		#print()
		#
		## Round 1
		#print(player_detail)
		#end_turn(0, hang_around_card)
		#end_turn(1, robin_hood_card)
		#print(player_detail)
		#end_round()
		#print(player_detail)
		#print("FIN RONDA 2")
		#print()
#
		## Round 2
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

func end_round():
	# Play cards and add points in order
	for player_position in len(player_detail):
		# TODO: await animations
		player_detail[player_position]["card_played"].play(player_position)

	# Add passive_clock
	for player in players:
		player.round_points += player.passive_clock * reverse_flow
		player.clock += player.round_points

	# Return to initial values
	for player in player_detail:
		player["card_played"] = null
		player["player"].round_points = 0

	if reverse_flow != 1: # To prevent UI update twice
		reverse_flow = 1

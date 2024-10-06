extends Node2D

@onready var clock_node = $Clock
@export var passive_clock : int = 30: # Minutes
	set(new_value):
		passive_clock = new_value
		# TODO: update passive clock in UI
		print(self.name, " passive_clock ", passive_clock)

# 1 point = 1 minute in clock
@export var clock : int = 0:
	set(new_value):
		new_value = clamp(new_value, 0, 720)
		await clock_node.get_node("ClockHand").move_hand(clock, new_value)
		clock = new_value
		print(self.name, " clock ", clock)

@export var round_points : int = 0:
	set(new_value):
		round_points = new_value
		# TODO: update points in UI, hide if round_points = 0
		print(self.name, " round_points ", round_points)

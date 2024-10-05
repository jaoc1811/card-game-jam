extends Node

# TODO: add hand, clock

@export var passive_clock : int = 30: # Minutes
	set(new_value):
		passive_clock = new_value
		# TODO: update passive clock in UI
		print(self.name, " passive_clock ", passive_clock)

# 1 point = 1 minute in clock
@export var clock : int = 0:
	set(new_value):
		clock = clamp(new_value, 0, 720)
		# TODO: update clock in UI
		print(self.name, " clock ", clock)

@export var round_points : int = 0:
	set(new_value):
		round_points = new_value
		# TODO: update points in UI, hide if round_points = 0
		print(self.name, " round_points ", round_points)

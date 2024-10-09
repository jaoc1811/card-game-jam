extends Node2D

@onready var clock_node = $Clock
@onready var passive_clock_label: Label = $"Passive Clock"
@onready var round_points_label: Label = $"Round Points"

@export var passive_clock : int = 30: # Minutes
	set(new_value):
		passive_clock = new_value
		passive_clock_label.text = get_points_str(passive_clock)

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
		round_points_label.text = get_points_str(round_points)


func get_clock_hours(points: int) -> int:
	return points/60


func get_clock_minutes(points: int)  -> int:
	return points%60


func get_points_str(points: int):
	var points_str = str(abs(get_clock_hours(points))) + "h"
	var minutes = get_clock_minutes(points)
	print(self.name, " points ", points, " minutes ", minutes)
	if minutes != 0:
		points_str += " " + str(abs(minutes)) + "min"
	if points >= 0:
		points_str = "+" + points_str
	else:
		points_str = "-" + points_str
	return points_str

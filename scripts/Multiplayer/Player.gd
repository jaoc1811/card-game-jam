extends RefCounted

class_name Player

var id: int = 0
var alias: String = ""
var last_card: int = 0 

func _init(_id: int):
	id = _id
	
func set_name(_alias: String):
	alias = _alias

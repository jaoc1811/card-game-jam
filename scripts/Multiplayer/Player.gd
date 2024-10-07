extends RefCounted

class_name Player

var id: int = 0
var lobby_key: = ""
var state: State = State.created

enum State {
	created, waiting, ready
}

func _init(_id: int):
	id = _id
	
func to_dict():
	return {
		"id" = id,
		"lobby_key" = lobby_key,
		"state" = state 
	}

func set_lobby_key(_lobby_key: String):
	lobby_key = _lobby_key
	
func set_state(_state: State):
	state = _state

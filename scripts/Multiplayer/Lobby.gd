extends RefCounted

class_name Lobby

var host: int
var players: Dictionary = {}
var key: String = ""
var state: State = State.waiting

enum State {
	waiting, all_ready, game_started, game_ongoing, game_ended
}

func _init(_player : Player, _key: String):
	host = _player.id
	key = _key

func to_dict():
	return {
		"host": host,
		"players": players,
		"key": key,
		"state": state
	}

func add_player(player : Player):
	players[player.id] = player
	
func setState(_state: State):
	state = _state

extends RefCounted

class_name Lobby

var host : int
var players : Dictionary = {} # <int, Player>
var key : String = ""

func _init(_player : Player, _key: String):
	host = _player.id
	key = _key

func to_dict():
	return {
		"host": host,
		"players": players,
		"key": key
	}

func add_player(player : Player):
	players[player.id] = player

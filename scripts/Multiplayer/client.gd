extends Peer

# Data
var id = 0
var player = null

# UI
var item_list = null

func _ready() -> void:
	item_list = get_node("/root/Multiplayer/Home/LobbyBoard/Lobbies")
	pass

func _process(delta: float) -> void:
	socket.poll()
	
	if socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		if packet != null:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			print(data)
			
			if data.message == SignalType.id:
				id = data.id
			
			if data.message == SignalType.lobby:
				player = data.player
				
			if data.message == SignalType.update:
				update_ui(data)

func start(ip):
	socket.create_client("ws://" + address + ":" + port)
	print("Client started at ws://" + address + ":" + port)

func update_ui(data):
	# Scene selection
	if player != null && player.state == Player.State.waiting:
		get_node("/root/Multiplayer/Lobby").visible = true
		get_node("/root/Multiplayer/Home").visible = false
	
	# Lobby list
	if get_node("/root/Multiplayer/Home").visible == true:
		item_list.clear()
		var lobbies = data["lobbies"]
		for lobby_key in lobbies.keys():
			var lobby = lobbies[lobby_key]
			var players = lobby.players
			item_list.add_item(lobby_key + " (" + str(players.size()) + ") ")

# UI
func _on_start_client_button_down() -> void:
	start("") 

func _on_send_package_button_down() -> void:
	var data = {
		"id": id,
		"message": SignalType.join
	}
	send_package(null, data)

func _on_join_button_button_down() -> void:
	send_package(null, {
		"id": id,
		"message": SignalType.lobby,
		"lobby_key": get_node("/root/Multiplayer/Home/LobbyBoard/LobbyKey").text
	})


func _on_ready_button_toggled(toggled_on: bool) -> void:
	send_package(null, {
		"id": id,
		"message": SignalType.player_ready,
		"lobby_key": player.lobby_key,
		"value": toggled_on
	})

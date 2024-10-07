extends Peer

var clients = {}
var lobbies: Dictionary = {} # <String, Lobby>

func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		print("hosting on " + str(port))
		socket.create_server(port)
	
	socket.connect("peer_connected", peer_connected)
	socket.disconnect("peer_disconnected", peer_disconnected)
	pass


func _process(delta: float) -> void:
	socket.poll()
	
	if socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		if packet != null:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			print(data)
			
			if data.message == SignalType.lobby:
				join_lobby(data.id, data.lobby_key)
				
			if data.message == SignalType.player_ready:
				handle_player_ready(data.id, data.lobby_key, data.value)
			
			update_client(data.id)


func start():
	socket.create_server(port.to_int())
	print("Server started in port " + port)

func peer_connected(id):
	clients[id] = {
		"id": id,
		"message": SignalType.id
	}
	send_package(id, clients[id])
	pass
	
func peer_disconnected(id):
	clients.erase(id)
	pass
	
func join_lobby(client_id: int, lobby_key: String):
	var player = Player.new(client_id)
	player.set_state(Player.State.waiting)
	
	# Inicializa el lobby y define player como host
	if lobby_key == "":
		lobby_key = generate_key()
		lobbies[lobby_key] = Lobby.new(player, lobby_key)

	player.set_lobby_key(lobby_key)
	if lobbies.has(lobby_key):
		lobbies[lobby_key].add_player(player)
		lobby_response(client_id, lobby_key)

func handle_player_ready(client_id: int, lobby_key: String, value: bool):
	var player = lobbies[lobby_key].players[client_id]
	player.set_state(Player.State.ready)
	lobby_response(client_id, lobby_key)
	
func lobby_response(client_id: int, lobby_key: String):
	send_package(client_id, {
		"message": SignalType.lobby,
		"id": client_id,
		"host": lobbies[lobby_key].host,
		"player": lobbies[lobby_key].players[client_id].to_dict(),
	})

func update_client(id):
	var lobbies_dict = {}
	for lobby in lobbies.keys():
		lobbies_dict[lobby] = lobbies[lobby].to_dict()
	
	send_package(id, {
		"id": id,
		"message": SignalType.update,
		"lobbies": lobbies_dict,
	})

# UI
func _on_start_server_button_down() -> void:
	start()

func _on_send_test_to_client_button_down() -> void:
	var data = {
		"id": 0,
		"message": SignalType.ping
	}
	send_package(null, data)

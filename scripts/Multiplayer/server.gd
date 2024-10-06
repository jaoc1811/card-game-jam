extends Peer

var clients = {}
var lobbies: Dictionary = {} # <String, Lobby>

func _ready() -> void:
	socket.connect("peer_connected", peer_connected)
	socket.disconnect("peer_disconnected", peer_disconnected)


func _process(delta: float) -> void:
	socket.poll()
	
	if socket.get_available_packet_count() > 0:
		var packet = socket.get_packet()
		if packet != null:
			var data = JSON.parse_string(packet.get_string_from_utf8())
			print(data)
			
			if data.message == SignalType.lobby:
				join_lobby(data.id, data.lobby_Key)
			
			# Update clients with new state
			send_package(null, {
				"id": data.id,
				"message": SignalType.update,
				"lobbies": lobbies
			})


func start():
	socket.create_server(port.to_int())
	print("Server started in port " + port)

func peer_connected(id):
	clients[id] = {
		"id": id,
		"message": SignalType.id
	}
	send_package(id, clients[id])
	
func peer_disconnected(id):
	clients.erase(id)
	
func join_lobby(client_id: int, lobby_key: String):
	var player = Player.new(client_id)
	
	# Inicializa el lobby y define player como host
	if lobby_key == "":
		lobby_key = generate_key()
		lobbies[lobby_key] = Lobby.new(player, lobby_key)

	if lobbies.has(lobby_key):
		lobbies[lobby_key].add_player(player)

		send_package(client_id, {
			"message": SignalType.connected,
			"id": client_id,
			"host": lobbies[lobby_key].host,
			"player": lobbies[lobby_key].players[client_id]
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

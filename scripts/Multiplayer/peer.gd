extends Node

class_name Peer
	
enum SignalType {
	id, join, connected, disconected, lobby, ping, update
}

var socket = WebSocketMultiplayerPeer.new()
var port = "8915"
var address = "127.0.0.1"
var key_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-.,<>/?"


func send_package(peer, data):
	var ws = socket
	if peer != null:
		ws = socket.get_peer(peer)
		
	ws.put_packet(JSON.stringify(data ).to_utf8_buffer())

func generate_key():
	var result = ""
	for i in range(4):
		var idx = randi() % key_characters.length()
		result += key_characters[idx]
	
	return result

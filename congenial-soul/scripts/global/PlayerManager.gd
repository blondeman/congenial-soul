extends Node

var players := {} # { peer_id: { "username": String, "color": Color } }
signal data_changed()

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	NetworkManager.server_started.connect(_on_peer_connected)

func _on_peer_connected(id: int = 1) -> void:
	if multiplayer.is_server():
		var username = "Player_%s" % id
		var color = Color(randf(), randf(), randf())
		players[id] = { "username": username, "color": color }

		rpc("client_sync_players", players)


func _on_peer_disconnected(id: int) -> void:
	players.erase(id)
	rpc("client_sync_players", players)


@rpc("any_peer", "call_local")
func client_sync_players(server_players: Dictionary) -> void:
	players = server_players.duplicate(true)
	data_changed.emit()


func get_player_data(id: int) -> Dictionary:
	if players.has(id):
		return players[id]
	return {}


func get_peer_list() -> Array:
	if !multiplayer.has_multiplayer_peer():
		return []
	var list := multiplayer.get_peers()

	#add own player
	if multiplayer.get_unique_id() not in list:
		list.append(multiplayer.get_unique_id())

	return list


func clear():
	players = {}
	data_changed.emit()

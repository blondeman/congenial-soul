extends Node

@onready var game_root = get_tree().get_first_node_in_group("game_root")
var player_scene: PackedScene = preload("res://scenes/player/player.tscn")
var player_data := {} # { peer_id: { "username": String, "color": Color } }
signal data_changed()

func _ready():
	if multiplayer.is_server():
		NetworkManager.server_started.connect(_on_peer_connected)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(delete_player)
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(clear)


func _on_peer_disconnected(id: int) -> void:
	player_data.erase(id)
	rpc("_client_sync_player_data", player_data)


func _on_peer_connected(id: int = 1) -> void:
	if multiplayer.is_server():
		var username = "Player_%s" % id
		var color = Color.from_hsv(randf(), 1, 1)
		player_data[id] = { "username": username, "color": color }

		rpc("_client_sync_player_data", player_data)
		spawn_player(id)


func spawn_player(id: int):
	if !multiplayer.is_server():
		return

	var player := player_scene.instantiate()
	player.name = str(id)
	player.position = Vector3(0, 2, 0)

	game_root.add_child(player)


func delete_player(id: int):
	if !multiplayer.is_server():
		return
	rpc("_delete_player", id)


@rpc("any_peer", "call_local")
func _delete_player(id: int):
	if game_root.has_node(str(id)):
		game_root.get_node(str(id)).queue_free()


@rpc("any_peer", "call_local")
func _client_sync_player_data(server_players: Dictionary) -> void:
	player_data = server_players.duplicate(true)
	data_changed.emit()


func get_player_data(id) -> Dictionary:
	if typeof(id) == TYPE_STRING:
		id = id.to_int()
	if player_data.has(id):
		return player_data[id]
	return {}


func clear():
	player_data = {}
	data_changed.emit()

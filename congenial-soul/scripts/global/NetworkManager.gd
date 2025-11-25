extends Node

var peer := ENetMultiplayerPeer.new()
var is_host := false

signal server_started()


func _ready() -> void:
	multiplayer.server_disconnected.connect(leave)


func host(port: int = 7777) -> void:
	var err := peer.create_server(port, 32)
	if err != OK:
		#push_error("Failed to start server: %s" % err)
		return

	multiplayer.multiplayer_peer = peer
	is_host = true

	print("Hosting server on port %s" % port)
	server_started.emit()


func join(ip: String, port: int = 7777) -> void:
	var err := peer.create_client(ip, port)
	if err != OK:
		#push_error("Failed to connect: %s" % err)
		return

	multiplayer.multiplayer_peer = peer
	is_host = false

	print("Connecting to %s:%s" % [ip, port])


func leave() -> void:
	print("Disconnecting…")
	peer.close()
	multiplayer.multiplayer_peer = null
	is_host = false
	get_tree().get_first_node_in_group("scene_manager").transition_to_menu()

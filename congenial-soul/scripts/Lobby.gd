extends Control

@export var player_list: VBoxContainer

func _ready() -> void:
	PlayerManager.data_changed.connect(set_player_list)


func _on_disconnect_pressed() -> void:
	NetworkManager.leave()
	PlayerManager.clear()
	get_tree().get_first_node_in_group("scene_manager").transition_to_menu()


func _on_join_pressed() -> void:
	NetworkManager.join("127.0.0.1")
	get_tree().get_first_node_in_group("scene_manager").transition_to_game()


func _on_host_pressed() -> void:
	NetworkManager.host()
	get_tree().get_first_node_in_group("scene_manager").transition_to_game()


func set_player_list():
	for child in player_list.get_children():
		child.queue_free()
	
	for peer_id in PlayerManager.player_data:
		var label: Label = Label.new()
		label.text = str(peer_id)
		
		var player_data = PlayerManager.get_player_data(peer_id)
		if player_data.size() > 0:
			label.add_theme_color_override("font_color", player_data["color"])
			label.text = player_data["username"]
		
		player_list.add_child(label)


func _on_debug_pressed() -> void:
	print(PlayerManager.players)

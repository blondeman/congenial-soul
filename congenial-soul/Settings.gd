extends CanvasLayer

@export var pause_menu: Control
@export var settings_menu: Control


func _ready():
	close()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close()
		else:
			navigate(pause_menu)


func navigate(menu: Control):
	visible = true
	pause_menu.visible = false
	settings_menu.visible = false
	menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close():
	visible = false
	if get_tree().get_first_node_in_group("scene_manager").is_in_game:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_pressed() -> void:
	close()


func _on_options_pressed() -> void:
	navigate(settings_menu)


func _on_back_pressed() -> void:
	navigate(pause_menu)

@abstract class_name Vessel extends CharacterBody3D

@export var speed: float = 10
@export var jump_force: float = 10
@export var mesh: MeshInstance3D
@export var default_color: Color = Color.LIGHT_GRAY

func _enter_tree():
	set_multiplayer_authority(0)


func _ready() -> void:
	clear_color()


func clear_color():
	set_color(default_color)


func set_color(color: Color):
	var material = mesh.get_surface_override_material(0) as StandardMaterial3D
	material.albedo_color = color
	mesh.set_surface_override_material(0, material)


func _process(delta: float):
	if !multiplayer.multiplayer_peer:
		return
	if !is_multiplayer_authority():
		return
	
	_process_horizontal(delta)
	_process_vertical(delta)
	_process_abilities(delta)


func _process_horizontal(_delta: float):
	var input_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up")).normalized()
	var forward = -get_viewport().get_camera_3d().global_transform.basis.z
	var right = get_viewport().get_camera_3d().global_transform.basis.x

	var direction = (right * input_direction.x) + (forward * input_direction.y)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func _process_vertical(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
	else:
		velocity.y += get_gravity().y * delta


func _process_abilities(_delta: float):
	if Input.is_action_just_pressed("ability_one"):
		use_ability(1)
	if Input.is_action_just_pressed("ability_two"):
		use_ability(2)
	if Input.is_action_just_pressed("ability_three"):
		use_ability(3)


func _physics_process(_delta: float):
	move_and_slide()


func use_ability(ability_id: int):
	rpc_id(1, "_server_ability", ability_id)


@rpc("any_peer", "call_local")
func _server_ability(ability_id: int):
	if !multiplayer.is_server():
		return
	
	rpc("_client_ability", ability_id)


@rpc("any_peer", "call_local")
func _client_ability(ability_id: int):
	match ability_id:
		1:
			_use_ability_one()
		2:
			_use_ability_two()
		3:
			_use_ability_three()


@abstract
func _use_ability_one()

@abstract
func _use_ability_two()

@abstract
func _use_ability_three()

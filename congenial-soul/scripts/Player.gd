extends CharacterBody3D

var id: int = 0
var current_vessel: Vessel = null

@export var hover_height := 1
@export var hover_strength := 70.0
@export var hover_damping := 10.0
@export var speed: float = 10

@export var mesh: MeshInstance3D
@export var camera: Camera3D
@export var ray: RayCast3D


func _enter_tree() -> void:
	id = name.to_int()
	set_multiplayer_authority(id)


func _ready() -> void:
	set_color()
	PlayerManager.data_changed.connect(set_color)
	
	if is_multiplayer_authority():
		camera.current = true


func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if current_vessel != null:
		return

	var input_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up")).normalized()
	var forward = -get_viewport().get_camera_3d().global_transform.basis.z
	var right   =  get_viewport().get_camera_3d().global_transform.basis.x

	var direction = (right * input_direction.x) + (forward * input_direction.y)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func _physics_process(delta: float) -> void:
	if current_vessel != null:
		return
		
	if ray.is_colliding():
		var collision_y = ray.get_collision_point().y
		var current_height = global_position.y - collision_y
		var error = hover_height - current_height
		var force = error * hover_strength
		force -= velocity.y * hover_damping
		velocity.y += force * delta
	else:
		velocity.y += get_gravity().y * delta

	move_and_slide()


func set_color():
	if PlayerManager.get_player_data(name.to_int()).has("color"):
		var color = PlayerManager.get_player_data(name.to_int())["color"]
		var material = mesh.get_surface_override_material(0) as ShaderMaterial
		material.set_shader_parameter("base_color", color)
		mesh.set_surface_override_material(0, material)


func _unhandled_input(event):
	if !is_multiplayer_authority():
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cam := get_viewport().get_camera_3d()
		if cam == null:
			return

		var mouse_pos = get_viewport().get_mouse_position()
		var from = cam.project_ray_origin(mouse_pos)
		var to = from + cam.project_ray_normal(mouse_pos) * 1000.0

		var query := PhysicsRayQueryParameters3D.create(from, to)
		var hit = get_world_3d().direct_space_state.intersect_ray(query)

		if hit and hit.collider is Vessel:
			if hit.collider == current_vessel:
				leave_vessel()
			else:
				enter_vessel(hit.collider)


func enter_vessel(vessel: Vessel):
	rpc_id(1, "_server_enter_vessel", vessel.get_path())


@rpc("any_peer", "call_local")
func _server_enter_vessel(vessel_path: NodePath):
	if !multiplayer.is_server():
		return
	
	var vessel = get_node(vessel_path) as Vessel
	if vessel.get_multiplayer_authority() == 0:
		rpc("_enter_vessel", vessel.get_path())


@rpc("any_peer", "call_local")
func _enter_vessel(vessel_path: NodePath):
	var vessel = get_node(vessel_path) as Vessel
	vessel.set_multiplayer_authority(id)
	current_vessel = vessel
	visible = false


func leave_vessel():
	rpc_id(1, "_server_leave_vessel")


@rpc("any_peer", "call_local")
func _server_leave_vessel():
	if !multiplayer.is_server():
		return
	
	rpc("_leave_vessel")


@rpc("any_peer", "call_local")
func _leave_vessel():
	current_vessel.set_multiplayer_authority(0)
	current_vessel = null
	visible = true

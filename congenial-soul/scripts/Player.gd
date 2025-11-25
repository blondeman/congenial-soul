extends CharacterBody3D

@export var hover_height := 1
@export var hover_strength := 70.0
@export var hover_damping := 10.0
@export var speed: float = 10

@export var mesh: MeshInstance3D
@export var camera: Camera3D
@export var ray: RayCast3D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	set_color()
	PlayerManager.data_changed.connect(set_color)
	
	if is_multiplayer_authority():
		camera.current = true


func _process(_delta: float) -> void:
	if !multiplayer.has_multiplayer_peer():
		return
	if !is_multiplayer_authority():
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
	

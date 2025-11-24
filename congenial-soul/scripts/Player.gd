extends CharacterBody3D

@export var speed: float = 200
@export var hover_velocity: float = 50.0

@export  var floor_ray: RayCast3D
@export var mesh: MeshInstance3D

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	set_color()
	PlayerManager.data_changed.connect(set_color)


func _process(delta: float) -> void:
	if !multiplayer.has_multiplayer_peer():
		return
	if !is_multiplayer_authority():
		return

	# Horizontal movement input
	velocity.x = Input.get_axis("right", "left") * speed * delta
	velocity.z = Input.get_axis("down", "up") * speed * delta


func _physics_process(delta: float) -> void:
	if floor_ray.is_colliding():
		var distance = lerp(3.0, -0.2, global_position.y - floor_ray.get_collision_point().y)
		velocity.y += hover_velocity * distance * delta
	else:
		velocity.y += get_gravity().y * delta
	
	move_and_slide()


func set_color():
	if PlayerManager.get_player_data(name.to_int()).has("color"):
		var color = PlayerManager.get_player_data(name.to_int())["color"]
		var material = mesh.get_surface_override_material(0) as ShaderMaterial
		material.set_shader_parameter("base_color", color)
		mesh.set_surface_override_material(0, material)
	

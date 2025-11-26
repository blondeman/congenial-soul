@abstract class_name Vessel extends CharacterBody3D

@export var speed: float = 10

func _enter_tree():
	set_multiplayer_authority(0)


func _process(delta: float):
	if !is_multiplayer_authority():
		return
	
	var input_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("down", "up")).normalized()
	var forward = -get_viewport().get_camera_3d().global_transform.basis.z
	var right = get_viewport().get_camera_3d().global_transform.basis.x

	var direction = (right * input_direction.x) + (forward * input_direction.y)
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed


func _physics_process(delta: float):
	if !is_on_floor():
		velocity.y += get_gravity().y
	
	move_and_slide()


@abstract 
func test2()

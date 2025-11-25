extends Node3D

@export var floor_ray: RayCast3D

func _process(delta: float) -> void:
	var target_position: Vector3
	if floor_ray.is_colliding():
		target_position = floor_ray.get_collision_point()
	else:
		target_position = floor_ray.global_position
	
	global_position = target_position


var rot_x = 0
var rot_y = 0
var LOOKAROUND_SPEED = .1

func _input(event):
	if event is InputEventMouseMotion and event.button_mask & 1:
		rot_x += event.relative.x * LOOKAROUND_SPEED
		rot_y += event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

class_name CameraController extends SpringArm3D

var current_target = null
@export var camera: Camera3D
@export var sensitivity: float = 0.003

func set_current():
	camera.current = true


func set_target(target: Node3D):
	current_target = target
	self.reparent(target)


func _process(delta: float) -> void:
	if current_target:
		global_position = lerp(global_position, current_target.global_position, delta * 5)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if current_target:
			rotation.x -= event.relative.y * sensitivity
			rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(70))
			
			rotation.y -= event.relative.x * sensitivity
			rotation.y = wrapf(rotation.y, 0, TAU)

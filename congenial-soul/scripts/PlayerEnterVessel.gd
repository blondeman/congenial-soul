extends Node3D

@export var travel_time: float = 2.0
var elapsed: float = 0
var start_position: Vector3 = Vector3.ZERO
var target: Node3D = null

signal arrived()

func _process(delta: float) -> void:
	if target == null:
		return
	
	elapsed += delta
	var t: float = clamp(elapsed / travel_time, 0.0, 1.0)

	var distance = start_position.distance_to(target.global_position)
	var control := (start_position + target.global_position) / 2.0 + Vector3(0, distance / 2, 0)
	global_position = bezier_point(start_position, control, target.global_position, t)

	if t >= 1.0:
		target = null
		arrived.emit()


func set_target(_target: Node3D):
	target = _target
	start_position = global_position
	elapsed = 0.0


func bezier_point(p0: Vector3, p1: Vector3, p2: Vector3, t: float) -> Vector3:
	return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2

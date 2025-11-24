extends CharacterBody3D

var speed = 200

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = Input.get_axis("right", "left") * delta * speed
	velocity.z = Input.get_axis("down", "up") * delta * speed

func _physics_process(delta: float) -> void:
	move_and_slide()

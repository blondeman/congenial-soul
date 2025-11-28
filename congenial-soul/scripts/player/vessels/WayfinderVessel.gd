extends Vessel

@export var glide_velocity = -2

func _use_ability_one():
	print("ONE")


func _use_ability_two():
	print("TWO")


func _use_ability_three():
	print("THREE")


func _process_vertical(delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
	else:
		if Input.is_action_pressed("jump") and velocity.y <= glide_velocity:
			velocity.y = glide_velocity
		else:
			velocity.y += get_gravity().y * delta

extends Vessel

@export var glide_velocity = -2
@export var slide_velocity = -2
@export var wall_coyote_time := 0.15

var wall_coyote_timer := 0.0
var stored_velocity: Vector3
var last_wall_normal: Vector3


func _use_ability_one():
	print("ONE")


func _use_ability_two():
	print("TWO")


func _use_ability_three():
	print("THREE")


func _process_vertical(delta: float):
	if is_on_wall_only():
		stored_velocity = velocity
		last_wall_normal = get_last_slide_collision().get_normal()
		wall_coyote_timer = wall_coyote_time
	else:
		wall_coyote_timer = max(wall_coyote_timer - delta, 0.0)
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_pressed("jump") and velocity.y <= glide_velocity:
		velocity.y = glide_velocity
	elif is_on_wall_only() and velocity.y < slide_velocity:
		velocity.y = slide_velocity
	else:
		velocity.y += get_gravity().y * delta

	if Input.is_action_just_pressed("jump"):
		if wall_coyote_timer > 0.0:
			var velocity_normal = stored_velocity.normalized()
			var alignment = velocity_normal.dot(last_wall_normal)
			if alignment < 0.5:
				stored_velocity = -last_wall_normal * jump_force
			velocity = stored_velocity.bounce(last_wall_normal)
			jump()
		elif coyote_timer > 0.0:
			jump()


func jump():
	super()
	wall_coyote_timer = 0

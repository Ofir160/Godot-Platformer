extends PlayerState
class_name CoyoteState

@export var air_state : PlayerState
@export var jump_state : PlayerState

var time_left_ground : float
var accel_rate : float
var move_input : float

func enter() -> void:
	super()
	time_left_ground = parent.current_time
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
	
	# If the player jumps in coyote time the jump will go through
	if Input.is_action_just_pressed("jump"):
		return jump_state
		
	# If coyote time is finished move to air state
	if parent.current_time - time_left_ground > stats.coyote_time:
		return air_state
	
	return null

func physics_update(delta : float) -> State:
	var target_speed : float = move_input * stats.move_speed
	
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
	else:
		accel_rate = 0
	
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	parent.body.velocity.y += stats.initial_gravity * delta
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null

func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and input > 0.01

extends PlayerState
class_name DoubleJumpState

@export var air_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	# When double jumping reduce previous upward momentum
	parent.body.velocity.y *= 0.3
	parent.body.velocity.y -= stats.double_jump_force
		
	if not is_speeding(move_input):
		# Dampens horizontal momentum
		parent.body.velocity.x *= stats.jump_velocity_damping
	else:
		# Boosts horizontal speed
		parent.body.velocity.x *= stats.double_jump_velocity_boost
	
	# Sets the time jumped to the current time
	PlayerState.time_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

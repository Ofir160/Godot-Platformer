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
	
	# Dampens vertical momentum
	parent.body.velocity.y *= stats.double_jump_vertical_damping
	
	# Adds the double jump jump force
	parent.body.velocity.y -= stats.double_jump_force
	
	# Check if speeding because I want double jumps when moving fast to give you a boost
	if not is_speeding(move_input):
		# Dampens horizontal momentum
		parent.body.velocity.x *= stats.double_jump_horizontal_damping
	else:
		# Boosts horizontal speed
		parent.body.velocity.x *= stats.double_jump_speeding_horizontal_boost
	
	# Sets the jump cooldown timer
	parent.timer_manager.set_timer("Jump cooldown", stats.jump_cooldown)
	
	# Consumes the double jump
	PlayerState.double_jump_available = false
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state
	
func is_speeding(input : float) -> bool:
	return (abs(parent.body.velocity.x) > stats.max_speed
	 and sign(parent.body.velocity.x) == sign(input)
	 and abs(input) > 0.01)

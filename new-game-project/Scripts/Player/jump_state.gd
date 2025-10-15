extends PlayerState
class_name JumpState

@export var air_state : PlayerState
@export var dash_interruptable_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	# Dampens horizontal momentum
	parent.body.velocity.x *= stats.jump_velocity_damping
		
	# Adds the jump force to the player
	parent.body.velocity.y -= stats.jump_force
	
	# Sets the time jumped to the current time
	PlayerState.time_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state

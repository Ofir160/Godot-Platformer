extends PlayerState
class_name JumpState

@export var air_state : PlayerState
@export var dash_interruptable_state : PlayerState

func enter() -> void:
	super()
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	if previous_state == air_state:
		# When double jumping reduce previous upward momentum
		parent.body.velocity.y *= 0.3
		parent.body.velocity.y -= stats.double_jump_force
	elif previous_state == dash_interruptable_state:
		# When super dashing increase force
		pass
	else:
		# Adds the jump force to the player
		parent.body.velocity.y -= stats.jump_force
	
	# Sets the time jumped to the current time
	PlayerState.time_jumped = parent.current_time
	
	parent.body.move_and_slide()
	
func physics_update(delta : float) -> State:
	# If the player is not on the floor move to air state
	if not parent.body.is_on_floor():
		return air_state
		
	parent.body.move_and_slide()
	return null

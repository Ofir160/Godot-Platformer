extends PlayerState
class_name JumpState

@export var air_state : PlayerState
@export var dash_interruptable_state : PlayerState

func enter() -> void:
	super()
	
	# Adds the jump force to the player
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	# When double jumping reduce previous upward momentum
	if previous_state == air_state:
		parent.body.velocity.y *= 0.3
		parent.body.velocity.y -= stats.double_jump_force
	else:
		parent.body.velocity.y -= stats.jump_force
		
	if previous_state == dash_interruptable_state:
		parent.body.velocity.x *= 2
	
	PlayerState.time_jumped = parent.current_time
	
	parent.body.move_and_slide()
	
func physics_update(delta : float) -> State:
	if not parent.body.is_on_floor():
		return air_state
		
	parent.body.move_and_slide()
	return null

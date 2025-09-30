extends PlayerState
class_name JumpState

@export var air_state : PlayerState 

func enter() -> void:
	super()
	
	# Adds the jump force to the player
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	parent.body.velocity.y -= stats.jump_force
	
	PlayerState.time_jumped = parent.current_time
	
	parent.body.move_and_slide()
	
func physics_update(delta : float) -> State:
	if not parent.body.is_on_floor():
		return air_state
		
	parent.body.move_and_slide()
	return null

extends PlayerState
class_name WallJumpState

@export var wall_jump_damping_state : PlayerState 
@export var dash_interruptable_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	var dir : float = -sign(parent.body.get_wall_normal().x)
	
	# Adds the jump force to the player
	parent.body.velocity.y = min(parent.body.velocity.y * stats.wall_jump_velocity_damping, 0)
	parent.body.velocity.y -= stats.wall_jump_force.y
	
	move_input = Input.get_axis("move_left", "move_right")
	if abs(move_input) > 0.01:
		if sign(move_input) == dir:
			parent.body.velocity.x = stats.wall_jump_force.x * -dir * stats.wall_jump_back_mult
		else:
			parent.body.velocity.x = stats.wall_jump_force.x * -dir
	else:
		parent.body.velocity.x = stats.wall_jump_force.x * -dir
	
	if previous_state == dash_interruptable_state:
		print("Ahh")
	
	PlayerState.time_wall_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	return wall_jump_damping_state

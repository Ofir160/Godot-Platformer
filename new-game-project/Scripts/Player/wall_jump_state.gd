extends PlayerState
class_name WallJumpState

@export var wall_jump_damping_state : PlayerState 
@export var dash_interruptable_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	var dir : float = -sign(parent.body.get_wall_normal().x)
	
	# Dampens upwards momentum
	parent.body.velocity.y = min(parent.body.velocity.y * stats.wall_jump_velocity_damping, 0)
	
	if previous_state == dash_interruptable_state:
		# When super dashing increase force
		
		# Gets the player's movement direction
		var move_input : float = Input.get_axis("move_left", "move_right")
		
		if abs(PlayerState.dash_direction.y) > 0.01 and abs(PlayerState.dash_direction.x) < 0.01:
			# If doing an up superdash
			parent.body.velocity.y -= stats.superdash_wall_up_force.y
			parent.body.velocity.x += stats.superdash_wall_up_force.x * -dir
		elif abs(PlayerState.dash_direction.y) > 0.01:
			# If doing a diagonal superdash
			parent.body.velocity.y -= stats.superdash_wall_diagonal_force.y
			parent.body.velocity.x += stats.superdash_wall_diagonal_force.x * -dir
		else:
			# If doing a straight superdash
			parent.body.velocity.y -= stats.superdash_wall_straight_force.y
			parent.body.velocity.x += stats.superdash_wall_straight_force.x * -dir
	else:
		# Adds the jump force to the player
		parent.body.velocity.y -= stats.wall_jump_force.y
		
		# Gets the player's movement direction
		move_input = Input.get_axis("move_left", "move_right")
		# If the player is moving back into the wall
		if abs(move_input) > 0.01:
			if sign(move_input) == dir:
				parent.body.velocity.x = stats.wall_jump_force.x * -dir * stats.wall_jump_back_mult
			else:
				parent.body.velocity.x = stats.wall_jump_force.x * -dir
		else:
			parent.body.velocity.x = stats.wall_jump_force.x * -dir
	
	# Sets the time wall jumped to the current time
	PlayerState.time_wall_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	return wall_jump_damping_state

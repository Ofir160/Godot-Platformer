extends PlayerState
class_name SuperDashWallState

@export var wall_jump_damping_state : PlayerState 

var move_input : float

func enter() -> void:
	super()
	
	var dir : float = -sign(parent.body.get_wall_normal().x)
	
	# Dampens upwards momentum
	parent.body.velocity.y = min(parent.body.velocity.y * stats.wall_jump_velocity_damping, 0)
	
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
	
	# Sets the time wall jumped to the current time
	PlayerState.time_wall_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	return wall_jump_damping_state

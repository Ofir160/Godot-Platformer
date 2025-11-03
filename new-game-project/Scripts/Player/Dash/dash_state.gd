extends PlayerState
class_name DashState

@export var dash_interruptable_state : PlayerState

func enter() -> void:
	super()
	
	# Reduced the amount of dashes available
	PlayerState.dashes_available -= 1
	
	# Save velocity
	
	PlayerState.saved_dash_speed = abs(parent.body.velocity.x)
	
	# Dampen previous velocity
	
	parent.body.velocity.x *= stats.dash_horizontal_damping
	parent.body.velocity.y *= stats.dash_vertical_damping
	
	# Calculate the velocity and apply it
	
	var dash_force : Vector2 = PlayerState.dash_direction * stats.dash_length / stats.dash_time
	
	# If dashing in a different direction to the direction you are moving on the x axis
	if abs(parent.body.velocity.x) > 0.01 and abs(PlayerState.dash_direction.x) > 0.01 and sign(parent.body.velocity.x) != sign(PlayerState.dash_direction.x):
		parent.body.velocity.x = dash_force.x
	else:
		parent.body.velocity.x += dash_force.x
	# If dashing in a different direction to the direction you are moving on the y axis
	if abs(parent.body.velocity.y) > 0.01 and abs(PlayerState.dash_direction.y) > 0.01 and sign(parent.body.velocity.y) != sign(PlayerState.dash_direction.y):
		parent.body.velocity.y = dash_force.y
	else:
		parent.body.velocity.y += dash_force.y
	
	# Constrain velocity
	
	# If dashing horizontally set vertical movement to 0
	if abs(PlayerState.dash_direction.x) > 0.01 and abs(PlayerState.dash_direction.y) < 0.01:
		parent.body.velocity.y = 0
	# If dashing vertically set horizontal movement to 0
	if abs(PlayerState.dash_direction.y) > 0.01 and abs(PlayerState.dash_direction.x) < 0.01:
		parent.body.velocity.x = 0
	
func process_input() -> State:
	if Input.is_action_just_pressed("jump"):
		PlayerState.superdash_queued = true
		
		parent.timer_manager.set_timer("Super double jump delay", stats.super_double_jump_delay)
	
	return null
	
func physics_update(delta : float) -> State:
	return dash_interruptable_state

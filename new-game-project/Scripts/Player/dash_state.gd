extends PlayerState
class_name DashState

@export var dash_interruptable_state : PlayerState

var direction : Vector2
var time_started_dashing : float

func enter() -> void:
	super()
	
	# Reduced the amount of dashes available
	PlayerState.dashes_available -= 1
	
	# Gets the direction the player would like to dash
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	# If the dash was done without moving set the direction to the way the character is facing
	if abs(direction.x) < 0.01 and abs(direction.y) < 0.01:
		direction.x = -1 if parent.animated_sprite.flip_h else 1
	
	# Dampen previous velocity
	
	parent.body.velocity *= stats.dash_damping_mult
	
	# Calculate the velocity and apply it
	
	var dash_force : Vector2 = direction * stats.dash_length / stats.dash_time
	
	# If dashing in a different direction to the direction you are moving on the x axis
	if abs(parent.body.velocity.x) > 0.01 and abs(direction.x) > 0.01 and sign(parent.body.velocity.x) != sign(direction.x):
		parent.body.velocity.x = dash_force.x
	else:
		parent.body.velocity.x += dash_force.x
	# If dashing in a different direction to the direction you are moving on the y axis
	if abs(parent.body.velocity.y) > 0.01 and abs(direction.y) > 0.01 and sign(parent.body.velocity.y) != sign(direction.y):
		parent.body.velocity.y = dash_force.y
	else:
		parent.body.velocity.y += dash_force.y
	
	# Constrain velocity
	
	# If dashing horizontally set vertical movement to 0
	if abs(direction.x) > 0.01 and abs(direction.y) < 0.01:
		parent.body.velocity.y = 0
	# If dashing vertically set horizontal movement to 0
	if abs(direction.y) > 0.01 and abs(direction.x) < 0.01:
		parent.body.velocity.x = 0
	
	# Sets the time dashed to the current time
	time_dashed = parent.current_time
	
	# Sets the dash direction to the desired direction
	PlayerState.dash_direction = direction
	
func process_input() -> State:
	# If jumped mid-dash make sure it gets buffered
	if Input.is_action_just_pressed("jump"):
		PlayerState.time_jump_pressed = parent.current_time
	
	return null
	
func physics_update(delta : float) -> State:
	# Checks if the player has been in this state for long enough
	if parent.current_time - time_dashed > stats.dash_time * stats.dash_uninterruptable_percent:
		return dash_interruptable_state
		
	parent.body.move_and_slide()
	return null

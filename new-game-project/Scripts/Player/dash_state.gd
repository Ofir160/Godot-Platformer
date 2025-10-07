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
	
	# Calculate the velocity and apply it
	parent.body.velocity = direction * stats.dash_length / stats.dash_time
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

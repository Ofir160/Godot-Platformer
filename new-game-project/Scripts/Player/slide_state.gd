extends PlayerState
class_name SlideState

@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var air_state : PlayerState
@export var wall_jump_state : PlayerState
@export var dash_start_state : PlayerState
@export var super_dash_wall_state : PlayerState

var move_input : float
var dir : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	# Refill double jump
	PlayerState.double_jump_available = true
	
	# Save the direction of the wall
	dir = -sign(parent.body.get_wall_normal().x)
	
func process_input() -> State:
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Checks if the player dashed
	if is_dash_buffered() and dash_available():
		var looking_up : bool = Input.is_action_pressed("look_up")
		var looking_down : bool = Input.is_action_pressed("look_down")
		
		# Stops the player dashing straight into the wall
		var dashing_into_wall : bool = abs(move_input) > 0.01 and sign(move_input) == dir and not looking_up and not looking_down
		# Stops the player dashing straight into the wall when not moving
		var idle_dashing_into_wall : bool = abs(move_input) < 0.01 and (-1 if parent.animated_sprite.flip_h else 1) == dir and not looking_down and not looking_up
		
		if not dashing_into_wall and not idle_dashing_into_wall:
			return dash_start_state
	elif Input.is_action_just_pressed("dash"):
		PlayerState.time_dash_pressed = parent.current_time
	
	# Check if a jump is buffered
	if is_jump_buffered() and parent.body.is_on_wall():
		if parent.current_time - PlayerState.time_dashed < stats.late_superdash_buffer_time:
			return super_dash_wall_state
		else:
			return wall_jump_state
		
	return null

func physics_update(delta : float) -> State:
	# Makes the player cling to the wall
	parent.body.velocity.x = dir
	
	# Checks if the player slides to the ground
	if parent.body.is_on_floor():
		# If moving off the wall go to move state
		if abs(move_input) > 0.01 and sign(move_input) != dir:
			return move_state
		else:
			return idle_state
	# If the wall disappears go to air state
	if not parent.body.is_on_wall() and not parent.body.is_on_floor():
		return air_state
	
	# Decelerates by the difference in slide speed. Greater when the difference is bigger 
	var movement : float = (stats.slide_speed - parent.body.velocity.y) * stats.slide_acceleration
	
	# Checks if the player moves off the wall
	if dir != sign(move_input) and abs(move_input) > 0.01:
		return air_state
	else:
		parent.body.velocity.y += movement * delta
	
	# Make sure the player isn't falling too fast
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - PlayerState.time_jump_pressed < stats.wall_jump_buffer_time and PlayerState.time_jump_pressed > 0)) and parent.current_time - time_wall_jumped > stats.wall_jump_cooldown
	
func dash_available() -> bool:
	return PlayerState.dashes_available > 0 and (parent.current_time - time_dashed > stats.dash_cooldown or time_dashed < 0.01)

func is_dash_buffered() -> bool:
	return Input.is_action_just_pressed("dash") or (parent.current_time - PlayerState.time_dash_pressed < stats.dash_buffer_time and PlayerState.time_dash_pressed > 0)

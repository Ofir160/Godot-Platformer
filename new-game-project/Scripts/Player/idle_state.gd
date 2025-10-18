extends PlayerState
class_name IdleState

@export var jump_state : PlayerState
@export var move_state : PlayerState
@export var air_state : PlayerState
@export var dash_start_state : PlayerState
@export var slide_state : PlayerState
@export var super_dash_state : PlayerState

var move_input : float
var on_wall : bool
var dir : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	# Checks if on a wall (more reliable than checking every frame)
	if previous_state == slide_state:
		on_wall = true
	else:
		on_wall = parent.body.is_on_wall()
	if on_wall:
		dir = -sign(parent.body.get_wall_normal().x)
	
	# Refill double jump
	PlayerState.double_jump_available = true
	
	parent.body.velocity.x = 0.0
	
func process_input() -> State:
	# Get the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Checks if the player has dashed
	if is_dash_buffered() and dash_available() and is_dash_direction_valid():
		return dash_start_state
	elif Input.is_action_just_pressed("dash"):
		parent.timer_manager.set_timer("Dash buffer", stats.dash_buffer_time)
	
	# Checks if a super dash is queued
	if PlayerState.superdash_queued and parent.current_time - PlayerState.time_dashed < stats.late_superdash_buffer_time:
		PlayerState.superdash_queued = false
		return super_dash_state
	
	# Check if a jump is buffered
	if is_jump_buffered() and is_jump_available():
		return jump_state
		
	return null

func physics_update(delta : float) -> State:
	# Checks if the player becomes in the air
	if not parent.body.is_on_floor():
		return air_state
	
	# Check if moving
	if abs(move_input) > 0.01:
		if on_wall:
			if sign(move_input) != dir:
				return move_state
		else:
			return move_state
	
	parent.body.move_and_slide()
	return null
	
# If you 
func is_jump_buffered() -> bool:
	return Input.is_action_just_pressed("jump") or not parent.timer_manager.query_timer("Jump buffer")

func is_jump_available() -> bool:
	return parent.timer_manager.query_timer("Jump cooldown") and parent.body.is_on_floor()

func dash_available() -> bool:
	return PlayerState.dashes_available > 0 and (parent.current_time - time_dashed > stats.dash_cooldown or time_dashed < 0.01)

func is_dash_buffered() -> bool:
	return Input.is_action_just_pressed("dash") or not parent.timer_manager.query_timer("Dash buffer")
	
func is_dash_direction_valid() -> bool:
	var looking_up : bool = Input.is_action_pressed("look_up")
	var looking_down : bool = Input.is_action_pressed("look_down")
	
	# Stops the dash if dashing down into the floor
	var dashing_down : bool = looking_down and abs(move_input) < 0.01
	# Stops the dash if dashing straight into a wall
	var dashing_into_wall : bool = abs(move_input) > 0.01 and sign(move_input) == dir and not looking_up and on_wall
	# Stops the dash if dashing straight into a wall but idle
	var idle_dashing_into_wall : bool = abs(move_input) < 0.01 and (-1 if parent.animated_sprite.flip_h else 1) == dir and not looking_down and not looking_up and on_wall
	return not dashing_down and not dashing_into_wall and not idle_dashing_into_wall

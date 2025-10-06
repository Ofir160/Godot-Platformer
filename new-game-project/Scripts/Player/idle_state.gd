extends PlayerState
class_name IdleState

@export var jump_state : PlayerState
@export var move_state : PlayerState
@export var air_state : PlayerState
@export var dash_state : PlayerState
@export var slide_state : PlayerState

var move_input : float
var on_wall : bool
var dir : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	# Checks if on a wall
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
	move_input = Input.get_axis("move_left", "move_right")
	
	# Check if a jump is buffered
	if is_jump_buffered() and parent.body.is_on_floor():
		return jump_state
		
	if Input.is_action_just_pressed("dash") and dash_available():
		var looking_up : bool = Input.is_action_pressed("look_up")
		var looking_down : bool = Input.is_action_pressed("look_down")
		
		var dashing_down : bool = looking_down and abs(move_input) < 0.01
		var dashing_into_wall : bool = abs(move_input) > 0.01 and sign(move_input) == dir and not looking_up and on_wall
		var idle_dashing_into_wall : bool = abs(move_input) < 0.01 and (-1 if parent.animated_sprite.flip_h else 1) == dir and not looking_down and not looking_up and on_wall
		if not dashing_down and not dashing_into_wall and not idle_dashing_into_wall:
			return dash_state
		
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
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - PlayerState.time_jump_pressed < stats.jump_buffer_time and PlayerState.time_jump_pressed > 0)) and parent.current_time - time_jumped > stats.jump_cooldown

func dash_available() -> bool:
	return (PlayerState.dashes_available > 0 and parent.current_time - time_dashed > stats.dash_cooldown) or time_dashed < 0.01

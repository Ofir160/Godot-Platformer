extends PlayerState
class_name IdleState

@export var jump_state : PlayerState
@export var move_state : PlayerState
@export var air_state : PlayerState
@export var dash_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	parent.body.velocity.x = 0.0
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	# Check if moving
	if abs(move_input) > 0.01:
		if parent.body.is_on_wall():
			var dir : float = -sign(parent.body.get_wall_normal().x)
			if sign(move_input) != dir:
				return move_state
		else:
			return move_state
	
	# Check if a jump is buffered
	if is_jump_buffered() and parent.body.is_on_floor():
		return jump_state
		
	if Input.is_action_just_pressed("dash") and PlayerState.dashes_available > 0:
		return dash_state
		
	return null

func physics_update(delta : float) -> State:
	# Checks if the player becomes in the air
	if not parent.body.is_on_floor():
		return air_state
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - time_jump_pressed_in_air < stats.jump_buffer_time and time_jump_pressed_in_air > 0)) and parent.current_time - time_jumped > stats.jump_cooldown

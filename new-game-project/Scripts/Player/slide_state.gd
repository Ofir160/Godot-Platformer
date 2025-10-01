extends PlayerState
class_name SlideState

@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var air_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	parent.body.velocity.x = 0.0
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	# Check if a jump is buffered
	#if is_jump_buffered() and parent.body.is_on_floor():
		#return jump_state
		
	return null

func physics_update(delta : float) -> State:
	# Checks if the player slides to the ground
	if parent.body.is_on_floor():
		if abs(move_input) > 0.01:
			return move_state
		else:
			return air_state
	elif not parent.body.is_on_wall():
		return air_state
	
	var dir : float = -sign(parent.body.get_wall_normal().x)
	
	if abs(move_input) > 0.01:
		if dir != sign(move_input):
			return air_state
	else:
		return air_state
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - time_jump_pressed < stats.jump_buffer_time and time_jump_pressed > 0)) and parent.current_time - time_jumped > stats.jump_cooldown

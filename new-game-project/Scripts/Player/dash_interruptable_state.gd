extends PlayerState
class_name DashInterruptableState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var slide_state : PlayerState
@export var jump_state : PlayerState
@export var wall_jump_state : PlayerState

var time_started_slowing_down : float
var time_floored : float
var time_walled : float
var floored : bool
var walled : bool
var dash_time : float

func enter() -> void:
	super()
	
	# Sets the time started slowing down to the current time (in order to know when to exit the state)
	time_started_slowing_down = parent.current_time
	# Sets the amount of time till the player should exit the state
	dash_time = stats.dash_time * (1 - stats.dash_uninterruptable_percent)
	
	floored = false
	walled = false
	
func process_input() -> State:
	# If super dashed on the floor
	if is_jump_buffered() and parent.body.is_on_floor():
		return jump_state
	# If super dashed on the wall
	if is_jump_buffered() and parent.body.is_on_wall():
		return wall_jump_state
	
	# If jumped when not on a wall or floor
	if Input.is_action_pressed("jump"):
		PlayerState.time_jump_pressed = parent.current_time
	
	return null
	
func physics_update(delta : float) -> State:
	# Checks if your dash hit an obstacle and stopped moving
	if parent.body.is_on_floor():
		if abs(parent.body.velocity.x) < 0.01:
			return idle_state
		elif not floored:
			time_floored = parent.current_time
			floored = true
	if parent.body.is_on_wall():
		if abs(parent.body.velocity.y) < 0.01:
			return slide_state
		elif not walled:
			time_walled = parent.current_time
			walled = true
	if parent.body.is_on_ceiling():
		if abs(parent.body.velocity.x) < 0.01:
			return air_state
	
	# Check if the dash has ended
	if parent.current_time - time_started_slowing_down > dash_time:
		# Sets the time dashed to the current time
		PlayerState.time_dashed = parent.current_time
		# If ended dash on the floor go to move state
		if parent.body.is_on_floor():
			return move_state
		else:
			if parent.body.velocity.y < 0:
				# If ended dash moving upwards decrease speed
				parent.body.velocity *= stats.dash_upwards_mult
			else:
				# If ended dash moving downwards increase speed
				parent.body.velocity *= stats.dash_downwards_mult
			return air_state
	
	if (floored and parent.current_time - time_floored > stats.dash_grounded_time_percent * dash_time) or (walled and parent.current_time - time_walled > stats.dash_grounded_time_percent * dash_time):
		PlayerState.dashes_available = stats.dashes
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_pressed("jump") or (parent.current_time - PlayerState.time_jump_pressed < stats.jump_buffer_time and PlayerState.time_jump_pressed > 0))

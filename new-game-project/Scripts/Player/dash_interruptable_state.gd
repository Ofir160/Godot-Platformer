extends PlayerState
class_name DashInterruptableState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var slide_state : PlayerState
@export var jump_state : PlayerState
@export var wall_jump_state : PlayerState

var time_started_slowing_down : float
var dash_time : float

func enter() -> void:
	super()
	
	time_started_slowing_down = parent.current_time
	dash_time = stats.dash_time * (1 - stats.dash_uninterruptable_percent)
	
func process_input() -> State:
	if is_jump_buffered() and parent.body.is_on_floor():
		return jump_state
	if is_jump_buffered() and parent.body.is_on_wall():
		return wall_jump_state
	
	if Input.is_action_pressed("jump"):
		PlayerState.time_jump_pressed = parent.current_time
	
	return null
	
func physics_update(delta : float) -> State:
	# Checks if your dash hit an obstacle and stopped moving
	if parent.body.is_on_floor():
		if abs(parent.body.velocity.x) < 0.01:
			return idle_state
	if parent.body.is_on_wall():
		if abs(parent.body.velocity.y) < 0.01:
			return slide_state
	if parent.body.is_on_ceiling():
		if abs(parent.body.velocity.x) < 0.01:
			return air_state
	
	# Check if the dash has ended
	if parent.current_time - time_started_slowing_down > dash_time:
		PlayerState.time_dashed = parent.current_time
		if parent.body.is_on_floor():
			return move_state
		else:
			parent.body.velocity *= stats.dash_upwards_mult
			return air_state
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_pressed("jump") or (parent.current_time - PlayerState.time_jump_pressed < stats.jump_buffer_time and PlayerState.time_jump_pressed > 0))

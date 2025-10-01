extends PlayerState
class_name MoveState

@export var idle_state : PlayerState
@export var jump_state : PlayerState
@export var coyote_state : PlayerState
@export var slide_state : PlayerState

var accel_rate : float
var move_input : float

func enter() -> void:
	super()
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
	
	# Checks if a jump is buffered
	if is_jump_buffered() and parent.body.is_on_floor():
		return jump_state
	
	return null

func physics_update(delta : float) -> State:
	# If you walked off a platform
	if not parent.body.is_on_floor():
		if parent.body.is_on_wall():
			var dir : float = -sign(parent.body.get_wall_normal().x)
			
			if abs(move_input) > 0:
				if sign(move_input) == dir:
					return slide_state
		else:
			return coyote_state
	
	var target_speed : float = move_input * stats.move_speed
	
	# Checks if you are going faster than the max speed
	if not is_speeding(move_input):
		accel_rate = stats.acceleration if abs(target_speed) > 0.01 else stats.deceleration
	else:
		accel_rate = 0
	
	var previous_velocity : float = parent.body.velocity.x
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	# Checks if you have stopped moving
	if abs(previous_velocity) > 0.01 and abs(parent.body.velocity.x) < 0.01:
		return idle_state
	
	parent.body.move_and_slide()
	return null

func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - time_jump_pressed < stats.jump_buffer_time and time_jump_pressed > 0)) and parent.current_time - time_jumped > stats.jump_cooldown
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and input > 0.01

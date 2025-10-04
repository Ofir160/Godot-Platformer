extends PlayerState
class_name SlideState

@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var air_state : PlayerState
@export var wall_jump_state : PlayerState

var move_input : float
var dir : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	dir = -sign(parent.body.get_wall_normal().x)
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	# Check if a jump is buffered
	if is_jump_buffered() and parent.body.is_on_wall():
		return wall_jump_state
		
	return null

func physics_update(delta : float) -> State:
	# Makes the player cling to the wall
	parent.body.velocity.x = dir
	
	# Checks if the player slides to the ground
	if parent.body.is_on_floor():
		if abs(move_input) > 0.01:
			return move_state
		else:
			return idle_state
	if not parent.body.is_on_wall() and not parent.body.is_on_floor():
		return air_state
		
	var movement : float = (stats.slide_speed - parent.body.velocity.y) * stats.slide_acceleration
	
	# Checks if the player moves off the wall
	if dir != sign(move_input) and abs(move_input) > 0.01:
		return air_state
	else:
		parent.body.velocity.y += movement * delta

	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (parent.current_time - time_jump_pressed_in_air < stats.jump_buffer_time and time_jump_pressed_in_air > 0)) and parent.current_time - time_wall_jumped > stats.wall_jump_cooldown

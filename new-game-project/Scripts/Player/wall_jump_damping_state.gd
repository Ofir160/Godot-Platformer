extends PlayerState
class_name WallJumpDampingState

@export var air_state : PlayerState
@export var dash_state : PlayerState

var accel_rate : float
var move_input : float
var time_entered : float
var dir : float
var move_back : bool

func enter() -> void:
	super()
	
	# Sets the time entered to the current time (in order to know when to leave the state)
	time_entered = parent.current_time
	# Saves the direction of the wall
	dir = -sign(parent.body.get_wall_normal().x)
	
func process_input() -> State:
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
		
	# Checks if the player dashed
	if Input.is_action_just_pressed("dash") and dash_available():
		return dash_state
	
	return null

func physics_update(delta : float) -> State:
	# Checks if the player has been in the state for enough time
	if parent.current_time - time_entered > stats.wall_jump_damping_time:
		return air_state
	
	var target_speed : float = move_input * stats.move_speed
	# Dampen the target speed reducing how much the player can move
	target_speed = lerp(target_speed, parent.body.velocity.x, 1 - stats.wall_jump_damping_strength)
	
	# Checks if you are going faster than the max speed
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
	else:
		accel_rate = stats.speeding_deceleration
		
	# If trying to move back into the wall increase acceleration rate
	if abs(move_input) > 0.01 and sign(move_input) == dir:
		accel_rate *= stats.wall_jump_move_back_mult
	
	# Accelerates by the difference in target speed. Greater when the difference is bigger
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	var gravity : float = stats.initial_gravity
	
	# Increases gravity if released jump button
	if not Input.is_action_pressed("jump"):
		gravity *= stats.wall_jump_release_gravity_mult
	
	# Apply gravity
	parent.body.velocity.y += gravity * delta
	# Make sure the player isn't falling too fast
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and input > 0.01
	
func dash_available() -> bool:
	return (PlayerState.dashes_available > 0 and parent.current_time - time_dashed > stats.dash_cooldown) or time_dashed < 0.01

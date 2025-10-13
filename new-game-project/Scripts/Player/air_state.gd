extends PlayerState
class_name AirState

@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var jump_state : PlayerState
@export var slide_state : PlayerState
@export var dash_state : PlayerState

var accel_rate : float
var move_input : float

func enter() -> void:
	super()
	
func process_input() -> State:
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
		
	# Checks if the player tried to double jump
	if Input.is_action_just_pressed("jump"):
		if PlayerState.double_jump_available:
			PlayerState.double_jump_available = false
			return jump_state
		else:
			# Sets the time jump was pressed to the current time (used for jump buffering)
			PlayerState.time_jump_pressed = parent.current_time
	
	# If the player tried to dash
	if Input.is_action_just_pressed("dash") and dash_available():
		return dash_state
	if Input.is_action_just_pressed("dash") and not dash_available():
		print(PlayerState.dashes_available)
	
	return null

func physics_update(delta : float) -> State:
	# If on the floor
	if parent.body.is_on_floor():
		# If moving when reached the floor go to move state
		if abs(move_input) > 0.01:
			return move_state
		else:
			return idle_state
	# If on the wall and not going up too much
	elif parent.body.is_on_wall() and parent.body.velocity.y > -stats.wall_jump_up_velocity_threshold:
		var dir : float = -sign(parent.body.get_wall_normal().x)
		
		# If not moving away from the wall
		if (abs(move_input) > 0.01 and sign(move_input) == dir) or abs(move_input) < 0.01:
			return slide_state
	
	var target_speed : float = move_input * stats.move_speed
	
	# Checks if you are going faster than the max speed
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
		if is_at_apex():
			# Adds extra speed at the height of the jump
			accel_rate *= stats.jump_apex_acceleration_mult
			target_speed *= stats.jump_apex_speed_mult
	else:
		accel_rate = stats.speeding_deceleration
	
	# Accelerates by the difference in target speed. Greater when the difference is bigger
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	var gravity : float = stats.initial_gravity
	
	# If previously jumped
	if previous_state == jump_state:
		if is_at_apex():
			# Decrease gravity at height of the jump
			gravity *= stats.jump_apex_gravity_mult
		if not PlayerState.double_jump_available:
			# Decrease gravity after a double jump
			gravity *= stats.double_jump_gravity_mult
		if not Input.is_action_pressed("jump"):
			# Increase gravity if released jump button
			gravity *= stats.jump_release_gravity_mult
		elif parent.body.velocity.y > 0:
			# Increase gravity if falling
			gravity *= stats.jump_fall_gravity_mult
	
	# Apply gravity
	parent.body.velocity.y += gravity * delta
	# Make sure the player isn't falling too fast
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null
	
func is_at_apex() -> bool:
	return previous_state == jump_state and abs(parent.body.velocity.y) < stats.jump_hang_time_threshold
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

func dash_available() -> bool:
	return PlayerState.dashes_available > 0 and (parent.current_time - time_dashed > stats.dash_cooldown or time_dashed < 0.01)

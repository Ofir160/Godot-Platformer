extends PlayerState
class_name CoyoteState

@export var air_state : PlayerState
@export var jump_state : PlayerState
@export var dash_start_state : PlayerState
@export var super_dash_state : PlayerState

var time_left_ground : float
var accel_rate : float
var move_input : float

func enter() -> void:
	super()
	time_left_ground = parent.current_time
	
func process_input() -> State:
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
	
	# Checks if dashed
	if is_dash_buffered() and dash_available():
		return dash_start_state
	elif Input.is_action_just_pressed("dash"):
		parent.timer_manager.set_timer("Dash buffer", stats.dash_buffer_time)
	
	# Checks if a super dash is queued
	if PlayerState.superdash_queued and parent.current_time - PlayerState.time_dashed < stats.late_superdash_buffer_time:
		PlayerState.superdash_queued = false
		return super_dash_state
	
	# If the player jumps in coyote time the jump will go through
	if Input.is_action_just_pressed("jump"):
		return jump_state
		
	# If coyote time is finished move to air state
	if parent.current_time - time_left_ground > stats.coyote_time:
		return air_state
	
	return null

func physics_update(delta : float) -> State:
	var target_speed : float = move_input * stats.move_speed
	
	# Checks if you are going faster than the max speed
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
	else:
		accel_rate = stats.speeding_deceleration
	
	# Accelerates by the difference in target speed. Greater when the difference is bigger
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	# Apply gravity
	parent.body.velocity.y += stats.initial_gravity * delta
	# Make sure the player isn't falling too fast
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null

func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

func dash_available() -> bool:
	return PlayerState.dashes_available > 0 and (parent.current_time - time_dashed > stats.dash_cooldown or time_dashed < 0.01)

func is_dash_buffered() -> bool:
	return Input.is_action_just_pressed("dash") or not parent.timer_manager.query_timer("Dash buffer")

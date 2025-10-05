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
	move_input = Input.get_axis("move_left", "move_right")
	
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
		
	if Input.is_action_just_pressed("jump"):
		PlayerState.time_jump_pressed_in_air = parent.current_time
		
	if Input.is_action_just_pressed("dash") and dash_available():
		return dash_state
	
	return null

func physics_update(delta : float) -> State:
	if parent.body.is_on_floor():
		if abs(move_input) > 0.01:
			return move_state
		else:
			return idle_state
	elif parent.body.is_on_wall() and parent.body.velocity.y > -stats.wall_jump_up_velocity_threshold:
		var dir : float = -sign(parent.body.get_wall_normal().x)
		
		if (abs(move_input) > 0.01 and sign(move_input) == dir) or abs(move_input) < 0.01:
			return slide_state
	
	var target_speed : float = move_input * stats.move_speed
	
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
		if is_at_apex():
			accel_rate *= stats.jump_apex_acceleration_mult
			target_speed *= stats.jump_apex_speed_mult
	else:
		accel_rate = stats.speeding_deceleration
	
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	var gravity : float = stats.initial_gravity
	
	if previous_state == jump_state:
		if is_at_apex():
			gravity *= stats.jump_apex_gravity_mult
		if not Input.is_action_pressed("jump"):
			gravity *= stats.jump_release_gravity_mult
		elif parent.body.velocity.y > 0:
			gravity *= stats.jump_fall_gravity_mult
			
	parent.body.velocity.y += gravity * delta
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null
	
func is_at_apex() -> bool:
	return previous_state == jump_state and abs(parent.body.velocity.y) < stats.jump_hang_time_threshold
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

func dash_available() -> bool:
	return (PlayerState.dashes_available > 0 and parent.current_time - time_dashed > stats.dash_cooldown) or time_dashed < 0.01

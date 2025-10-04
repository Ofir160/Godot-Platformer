extends PlayerState
class_name WallJumpDampingState

@export var air_state : PlayerState

var accel_rate : float
var move_input : float
var time_entered : float
var dir : float
var move_back : bool

func enter() -> void:
	super()
	time_entered = parent.current_time
	dir = -sign(parent.body.get_wall_normal().x)
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
	
	return null

func physics_update(delta : float) -> State:
	if parent.current_time - time_entered > stats.wall_jump_damping_time:
		return air_state
	
	var target_speed : float = move_input * stats.move_speed
	target_speed = lerp(target_speed, parent.body.velocity.x, 1 - stats.wall_jump_damping_strength)
	
	if not is_speeding(move_input):
		if abs(target_speed) > 0.01:
			accel_rate = stats.acceleration * stats.air_acceleration_mult
		else:
			accel_rate = stats.deceleration * stats.air_deceleration_mult
	else:
		accel_rate = stats.speeding_deceleration
		
	if abs(move_input) > 0.01 and sign(move_input) == dir:
		accel_rate *= stats.wall_jump_move_back_mult
	
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	var gravity : float = stats.initial_gravity
	
	if not Input.is_action_pressed("jump"):
		gravity *= stats.wall_jump_release_gravity_mult
	
	parent.body.velocity.y += gravity * delta
	parent.body.velocity.y = min(parent.body.velocity.y, stats.max_fall_speed)
	
	parent.body.move_and_slide()
	return null
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and input > 0.01

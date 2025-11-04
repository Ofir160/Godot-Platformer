extends PlayerState
class_name MoveState

@export var idle_state : PlayerState
@export var jump_state : PlayerState
@export var coyote_state : PlayerState
@export var dash_start_state : PlayerState
@export var super_dash_state : PlayerState
@export var attack_start_state : PlayerState

var accel_rate : float
var move_input : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	# Refill double jump
	PlayerState.double_jump_available = true
	
func process_input() -> State:
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Flips character depending on movement direction
	if move_input > 0:
		parent.sprite.flip_h = false
	elif move_input < 0:
		parent.sprite.flip_h = true
	
	# Checks if the player dashed
	if is_dash_buffered() and dash_available() and is_dash_direction_valid():
		return dash_start_state
	elif Input.is_action_just_pressed("dash"):
		parent.timer_manager.set_timer("Dash buffer", stats.dash_buffer_time)
	
	# If the player tried to attack
	if Input.is_action_just_pressed("attack"):
		return attack_start_state
	
	# Checks if a super dash is queued
	if PlayerState.superdash_queued and not parent.timer_manager.query_timer("Late superdash"):
		PlayerState.superdash_queued = false
		return super_dash_state
	
	# Checks if a jump is buffered
	if is_jump_buffered() and is_jump_available():
		if not parent.timer_manager.query_timer("Late superdash"):
			return super_dash_state
		else:
			return jump_state
	
	return null

func physics_update(delta : float) -> State:
	# If you walked off a platform
	if not parent.collision.is_on_floor(true):
		return coyote_state
	
	var target_speed : float = move_input * stats.move_speed
	
	# Checks if you are going faster than the max speed
	if not is_speeding(move_input):
		accel_rate = stats.acceleration if abs(target_speed) > 0.01 else stats.deceleration
	else:
		accel_rate = stats.speeding_deceleration
	
	# Save the velocity in order to check if stopped moving
	var previous_velocity : float = parent.body.velocity.x
	
	# Accelerates by the difference in target speed. Greater when the difference is bigger
	parent.body.velocity.x += (target_speed - parent.body.velocity.x) * accel_rate * delta
	
	# Checks if you have stopped moving
	if abs(previous_velocity) > 0.01 and abs(parent.body.velocity.x) < 0.01:
		return idle_state
	
	# If walking into a wall change state to idle state
	if parent.collision.is_on_wall(true):
		var dir : float = -sign(parent.collision.get_wall_side())
		if (sign(move_input) == dir and abs(move_input) > 0.01) or abs(move_input) < 0.01:
			return idle_state
	
	parent.body.move_and_slide()
	return null

func is_jump_buffered() -> bool:
	return Input.is_action_just_pressed("jump") or not parent.timer_manager.query_timer("Jump buffer")
	
func is_jump_available() -> bool:
	return parent.timer_manager.query_timer("Jump cooldown") and parent.collision.is_on_floor(false)
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

func dash_available() -> bool:
	return PlayerState.dashes_available > 0 and parent.timer_manager.query_timer("Dash cooldown")

func is_dash_buffered() -> bool:
	return Input.is_action_just_pressed("dash") or not parent.timer_manager.query_timer("Dash buffer")
	
func is_dash_direction_valid() -> bool:
	return not (Input.is_action_pressed("look_down") and abs(move_input) < 0.01)

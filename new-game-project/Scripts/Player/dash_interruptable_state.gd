extends PlayerState
class_name DashInterruptableState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var slide_state : PlayerState
@export var jump_state : PlayerState
@export var wall_jump_state : PlayerState
@export var super_dash_state : PlayerState
@export var super_dash_wall_state : PlayerState

var time_started : float
var time_floored : float
var time_walled : float

func enter() -> void:
	super()
	
	# Sets the time started 
	time_started = parent.current_time
	
	# Resets super dash queue
	PlayerState.superdash_queued = false
	
func process_input() -> State:
	# If super dashed on the floor
	if PlayerState.superdash_queued and parent.body.is_on_floor():
		if parent.current_time - time_started > stats.regain_dash_time:
			PlayerState.dashes_available = stats.dashes
		return super_dash_state
	# If super dashed on the wall
	if PlayerState.superdash_queued and parent.body.is_on_wall():
		if parent.current_time - time_started > stats.regain_dash_time:
			PlayerState.dashes_available = stats.dashes
		return super_dash_wall_state
	
	# If dashed whilst in a dash
	if Input.is_action_just_pressed("dash"):
		parent.timer_manager.set_timer("Dash buffer", stats.dash_buffer_time)
	
	# If jumped when not on a wall or floor
	if Input.is_action_pressed("jump") and parent.current_time - time_started > stats.early_superdash_time:
		PlayerState.superdash_queued = true
	
	return null
	
func physics_update(delta : float) -> State:
	# Checks if your dash hit an obstacle and stopped moving
	if parent.body.is_on_floor():
		if abs(parent.body.velocity.x) < 0.01:
			# Sets the time dashed to the current time
			PlayerState.time_dashed = parent.current_time
			return move_state
		elif parent.current_time - time_started > stats.regain_dash_time:
			# Refils dash if grounded after the regain dash time
			PlayerState.dashes_available = stats.dashes
	if parent.body.is_on_wall():
		if abs(parent.body.velocity.y) < 0.01:
			# Sets the time dashed to the current time
			PlayerState.time_dashed = parent.current_time
			return slide_state
		elif parent.current_time - time_started > stats.regain_dash_time:
			# Refils dash if walled after the regain dash time
			PlayerState.dashes_available = stats.dashes
	if parent.body.is_on_ceiling():
		if abs(parent.body.velocity.x) < 0.01:
			# Sets the time dashed to the current time
			PlayerState.time_dashed = parent.current_time
			return air_state
	
	# Check if the dash has ended
	if parent.current_time - time_started > stats.interruptable_dash_time:
		# Sets the time dashed to the current time
		PlayerState.time_dashed = parent.current_time
		# If ended dash on the floor go to move state
		if parent.body.is_on_floor():
			return move_state
		else:
			if PlayerState.dash_direction.y < 0.01:
				# If ended dash moving upwards decrease speed
				parent.body.velocity *= stats.dash_upwards_mult
			elif PlayerState.dash_direction.y > 0.01 and abs(PlayerState.dash_direction.x) > 0.01:
				# If ended dash moving downwards increase speed
				parent.body.velocity.x *= stats.dash_downwards_mult
			elif abs(PlayerState.dash_direction.y) < 0.01:
				# If ended dash moving horizontally decrease speed
				parent.body.velocity.x *= stats.dash_horizontal_mult
			if parent.body.is_on_wall():
				return slide_state
			else:
				return air_state
	
	parent.body.move_and_slide()
	return null

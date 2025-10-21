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
@export var super_double_jump_state : PlayerState

var time_started : float
var time_floored : float
var time_walled : float

func enter() -> void:
	super()
	
	# Sets the time started 
	time_started = parent.current_time
	
	# Sets the dash timer
	parent.timer_manager.set_timer("Dash", stats.interruptable_dash_time)
	
	# Sets the regain dash timer
	parent.timer_manager.set_timer("Regain dash", stats.regain_dash_time)
	
func process_input() -> State:
	
	# If dashed whilst in a dash
	if Input.is_action_just_pressed("dash"):
		parent.timer_manager.set_timer("Dash buffer", stats.dash_buffer_time)
	
	# If jumped when not on a wall or floor
	if Input.is_action_just_pressed("jump"):
		print("H")
		PlayerState.superdash_queued = true
		
		parent.timer_manager.set_timer("Super double jump delay", stats.super_double_jump_delay)
	
	return null
	
func physics_update(delta : float) -> State:
	
	if parent.body.is_on_floor():
		if abs(parent.body.velocity.x) < 0.01 and parent.body.velocity.y >= 0:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			# Sets the late superdash timer
			parent.timer_manager.set_timer("Late superdash", stats.late_superdash_time)
			
			return move_state
		elif parent.timer_manager.query_timer("Regain dash"):
			# Refils dash if grounded after the regain dash time
			PlayerState.dashes_available = stats.dashes
		if PlayerState.superdash_queued:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			if PlayerState.dash_direction.y >= 0:
				return super_dash_state
	
	if parent.body.is_on_wall():
		if abs(parent.body.velocity.y) < 0.01:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			# Sets the late superdash timer
			parent.timer_manager.set_timer("Late superdash", stats.late_superdash_time)
			
			return slide_state
		elif parent.timer_manager.query_timer("Regain dash"):
			# Refils dash if walled after the regain dash time
			PlayerState.dashes_available = stats.dashes
		if PlayerState.superdash_queued:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			return super_dash_wall_state
	
	if parent.body.is_on_ceiling():
		if abs(parent.body.velocity.x) < 0.01:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			return air_state
	
	if PlayerState.superdash_queued and parent.timer_manager.query_timer("Super double jump delay"):
		if not parent.body.is_on_floor() and not parent.body.is_on_wall():
			
			if parent.timer_manager.query_timer("Regain dash"):
				# Refils dash if walled after the regain dash time
				PlayerState.dashes_available = stats.dashes
			
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			if PlayerState.double_jump_available:
				return super_double_jump_state
	
	# Check if the dash has ended
	if parent.timer_manager.query_timer("Dash"):
		# Sets the dash cooldown timer
		parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
		
		# Sets the late superdash timer
		parent.timer_manager.set_timer("Late superdash", stats.late_superdash_time)
		
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

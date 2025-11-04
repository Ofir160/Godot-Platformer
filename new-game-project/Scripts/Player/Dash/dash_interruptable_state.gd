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
@export var attack_start_state : PlayerState

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
		PlayerState.superdash_queued = true
		
		parent.timer_manager.set_timer("Super double jump delay", stats.super_double_jump_delay)
	
	# If dash is cancelled
	if Input.is_action_just_pressed("attack") or PlayerState.dash_attack_queued:
		parent.timer_manager.kill_timer("Dash")
		parent.timer_manager.kill_timer("Regain dash")
		parent.timer_manager.kill_timer("Super double jump delay")
		
		return attack_start_state
	
	return null
	
func physics_update(delta : float) -> State:
	# If close to the ground
	if parent.collision.is_on_floor(false):
		if parent.timer_manager.query_timer("Regain dash"):
			# Refils dash if grounded after the regain dash time
			PlayerState.dashes_available = stats.dashes
		elif PlayerState.superdash_queued:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			if PlayerState.dash_direction.y >= 0:
				return super_dash_state
		
	# If on the ground and not moving
	if abs(parent.body.velocity.x) < 0.01 and parent.body.velocity.y >= 0 and parent.collision.is_on_floor(true):
		# Sets the dash cooldown timer
		parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
		# Sets the late superdash timer
		parent.timer_manager.set_timer("Late superdash", stats.late_superdash_time)
			
		return move_state
	
	# If close to the wall
	if parent.collision.is_on_wall(false):
		if parent.timer_manager.query_timer("Regain dash"):
			# Refils dash if walled after the regain dash time
			PlayerState.dashes_available = stats.dashes
		elif PlayerState.superdash_queued:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			return super_dash_wall_state
	
	# If on the wall and not moving
	if abs(parent.body.velocity.y) < 0.01 and parent.collision.is_on_wall(true):
		# Sets the dash cooldown timer
		parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
		
		# Sets the late superdash timer
		parent.timer_manager.set_timer("Late superdash", stats.late_superdash_time)
		
		return slide_state
	
	# If touching the ceiling
	if parent.collision.is_on_ceiling(true):
		if abs(parent.body.velocity.x) < 0.01:
			# Sets the dash cooldown timer
			parent.timer_manager.set_timer("Dash cooldown", stats.dash_cooldown)
			
			return air_state
	
	# If super double jumping
	if PlayerState.superdash_queued and parent.timer_manager.query_timer("Super double jump delay"):
		if not parent.collision.is_on_floor(false) and not parent.collision.is_on_wall(false):
			
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
		if parent.collision.is_on_floor(true):
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
			if parent.collision.is_on_wall(false):
				return slide_state
			else:
				return air_state
	
	parent.body.move_and_slide()
	return null

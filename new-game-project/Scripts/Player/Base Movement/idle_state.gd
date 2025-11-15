extends PlayerState
class_name IdleState

@export var jump_state : PlayerState
@export var move_state : PlayerState
@export var air_state : PlayerState
@export var dash_start_state : PlayerState
@export var slide_state : PlayerState
@export var super_dash_state : PlayerState
@export var attack_start_state : PlayerState

var move_input : float
var on_wall : bool
var dir : float

func enter() -> void:
	super()
	
	# Refill dashes
	if PlayerState.dashes_available < stats.dashes:
		PlayerState.dashes_available = stats.dashes
	
	# Refill double jump
	PlayerState.double_jump_available = true
	
	parent.body.velocity.x = 0.0
	
func process_input() -> State:
	# Get the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Checks if the player has dashed
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
	
	# Check if a jump is buffered
	if is_jump_buffered() and is_jump_available():
		# If jumping in the time after a dash do a superdash instead
		if not parent.timer_manager.query_timer("Late superdash"):
			return super_dash_state
		else:
			return jump_state
		
	return null

func physics_update(delta : float) -> State:
	# Checks if the player becomes in the air
	if not parent.collision.is_on_floor(true):
		return air_state
	
	# Check if moving
	if abs(move_input) > 0.01:
		if parent.collision.is_on_wall(false):
			if sign(move_input) != -parent.collision.get_wall_side():
				return move_state
		else:
			return move_state
	
	parent.body.move_and_slide()
	return null
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") 
	 or not parent.timer_manager.query_timer("Jump buffer"))

func is_jump_available() -> bool:
	return (parent.timer_manager.query_timer("Jump cooldown") 
	and parent.collision.is_on_floor(false))

func dash_available() -> bool:
	return (PlayerState.dashes_available > 0
	 and parent.timer_manager.query_timer("Dash cooldown"))

func is_dash_buffered() -> bool:
	return (Input.is_action_just_pressed("dash")
	 or not parent.timer_manager.query_timer("Dash buffer"))
	
func is_dash_direction_valid() -> bool:
	var looking_up : bool = Input.is_action_pressed("look_up")
	var looking_down : bool = Input.is_action_pressed("look_down")
	
	# Stops the dash if dashing down into the floor
	var dashing_down : bool = looking_down and abs(move_input) < 0.01
	
	# Stops the dash if dashing straight into a wall by checking if
	var dashing_into_wall : bool = (abs(move_input) > 0.01 
	 and sign(move_input) == -parent.collision.get_wall_side() 
	 and not looking_up and parent.collision.is_on_wall(false))
	
	# Stops the dash if dashing straight into a wall but idle
	var idle_dashing_into_wall : bool = (abs(move_input) < 0.01 
	 and (-1 if parent.sprite.flip_h else 1) == -parent.collision.get_wall_side() 
	 and not looking_down and not looking_up and parent.collision.is_on_wall(false))
	
	return not dashing_down and not dashing_into_wall and not idle_dashing_into_wall

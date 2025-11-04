extends PlayerState
class_name DashStartState

@export var dash_state : PlayerState

var time_started : float
var direction : Vector2

func enter() -> void:
	super()
	
	# Sets the dash start timer
	parent.timer_manager.set_timer("Dash start", stats.frozen_dash_time)
	
	# Gets the direction the player would like to dash
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	# If the dash was done without moving set the direction to the way the character is facing
	if abs(direction.x) < 0.01 and abs(direction.y) < 0.01:
		direction.x = -1 if parent.sprite.flip_h else 1
		
	# Sets the dash direction to the desired direction
	PlayerState.dash_direction = direction
	
	# Resets super dash queue
	PlayerState.superdash_queued = false
	
func process_input() -> State:
	
	var new_direction : Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	if (new_direction - direction).length() > 0.01 and (abs(new_direction.x) > 0.01 or abs(new_direction.y) > 0.01):
		direction = new_direction
		
		# Flips character depending on movement direction
		if new_direction.x > 0:
			parent.sprite.flip_h = false
		elif new_direction.x < 0:
			parent.sprite.flip_h = true
		
		# Sets the dash direction to the desired direction
		PlayerState.dash_direction = direction
		
		
		
	if Input.is_action_just_pressed("jump"):
		PlayerState.superdash_queued = true
		
		parent.timer_manager.set_timer("Super double jump delay", stats.super_double_jump_delay)
	
	if not parent.timer_manager.query_timer("Wall jump buffer"):
		PlayerState.superdash_queued = true
		
		parent.timer_manager.set_timer("Super double jump delay", stats.dash_time)
	
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Dash start"):
		return dash_state
		
	return null

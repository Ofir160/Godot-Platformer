extends PlayerState
class_name SuperDashStartState

@export var super_dash_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Sets the dash start timer
	parent.timer_manager.set_timer("Super dash start", stats.superdash_freeze_time)
	
	# Gets the direction the player would like to dash
	move_input = Input.get_axis("move_left", "move_right")
	
	# If the dash was done without moving set the direction to the way the character is facing
	if abs(move_input) < 0.01:
		move_input = -1 if parent.animated_sprite.flip_h else 1
		
	# Sets the superdash direction to the desired direction
	PlayerState.super_direction = move_input
	
func process_input() -> State:
	var new_move_input : float = Input.get_axis("move_left", "move_right")
	
	if abs(new_move_input) > 0.01 and sign(move_input) != sign(new_move_input):
		move_input = new_move_input
		
		print("Swapped directions")
		
		# Flips character depending on movement direction
		if move_input > 0:
			parent.animated_sprite.flip_h = false
		elif move_input < 0:
			parent.animated_sprite.flip_h = true
		
		# Sets the superdash direction to the desired direction
		PlayerState.super_direction = move_input
		
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Super dash start"):
		return super_dash_state
		
	return null

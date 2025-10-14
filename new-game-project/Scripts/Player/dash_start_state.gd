extends PlayerState
class_name DashStartState

@export var dash_state : PlayerState

var time_started : float
var direction : Vector2

func enter() -> void:
	super()
	
	# Records the time started dashing
	time_started = parent.current_time
	
	# Gets the direction the player would like to dash
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	# If the dash was done without moving set the direction to the way the character is facing
	if abs(direction.x) < 0.01 and abs(direction.y) < 0.01:
		direction.x = -1 if parent.animated_sprite.flip_h else 1
		
	# Sets the dash direction to the desired direction
	PlayerState.dash_direction = direction
	
func process_input() -> State:
	
	var new_direction : Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	if (new_direction - direction).length() > 0.01 and (abs(new_direction.x) > 0.01 or abs(new_direction.y) > 0.01):
		direction = new_direction

		# Sets the dash direction to the desired direction
		PlayerState.dash_direction = direction
	
	return null
	
func physics_update(delta : float) -> State:
	if parent.current_time - time_started > stats.frozen_dash_time:
		return dash_state
	
	parent.body.move_and_slide()
	return null

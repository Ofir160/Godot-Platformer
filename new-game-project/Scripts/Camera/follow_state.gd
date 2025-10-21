extends CameraState
class_name FollowState

var offset : float
var looking_left : bool
var starting_offset : float
var desired_offset : float

var new_x_position : float
var new_y_position : float

var player_falling : bool
var y_damping_strength : float
var starting_y_damping_strength : float
var desired_y_damping_strength : float

func enter() -> void:
	super()
	
	looking_left = parent.player.sprite.flip_h
	offset = stats.bias_length * (-1 if looking_left else 1)
	player_falling = parent.player.body.velocity.y > stats.y_damping_change_velocity_threshold
	y_damping_strength = stats.y_damping_strength_down if player_falling else stats.y_damping_strength_up
	
	starting_offset = offset
	desired_offset = stats.bias_length * (-1 if looking_left else 1)
	
	starting_y_damping_strength = y_damping_strength
	desired_y_damping_strength = stats.y_damping_strength_down if player_falling else stats.y_damping_strength_up
	
func physics_update(delta : float) -> State:
	# If turned around lerp the bias to the new position
	if looking_left != parent.player.sprite.flip_h:
		looking_left = parent.player.sprite.flip_h
		parent.timer_manager.set_timer("Bias turnaround", stats.bias_turnaround_time)
		starting_offset = offset
		desired_offset = stats.bias_length * (-1 if looking_left else 1)
	
	var time_left_turnaround : float = parent.timer_manager.check_timer("Bias turnaround")
	
	# Calculate the lerped bias position
	if time_left_turnaround > 0:
		var t = (stats.bias_turnaround_time - time_left_turnaround) / stats.bias_turnaround_time
		offset = lerp(starting_offset, desired_offset, -(cos(PI * t) - 1) / 2)
	
	var new_player_falling : bool = parent.player.body.velocity.y > stats.y_damping_change_velocity_threshold
	
	# If the player is now falling lerp the damping strength
	if player_falling != new_player_falling:
		player_falling = new_player_falling
		parent.timer_manager.set_timer("Y Damping lerp", stats.y_damping_change_time)
		starting_y_damping_strength = y_damping_strength
		desired_y_damping_strength = stats.y_damping_strength_down if player_falling else stats.y_damping_strength_up
	
	var time_left_y_damping : float = parent.timer_manager.check_timer("Y Damping lerp")
	
	# Calculate the lerped y damping
	if time_left_y_damping > 0:
		var t = (stats.y_damping_change_time - time_left_y_damping) / stats.y_damping_change_time
		y_damping_strength = lerp(starting_y_damping_strength, desired_y_damping_strength, 1 - (1 - t) * (1 - t) )
	
	var new_player_position_x = parent.player.position.x + parent.player.velocity.x * stats.lookahead_time
	
	
	# Calculate the new position on the x axis by lerp smoothing to the player with bias
	new_x_position = lerp(parent.position.x, new_player_position_x + offset, 1 - exp(-delta * stats.x_damping_strength))
	new_y_position = lerp(parent.position.y, parent.player.position.y, 1 - exp(-delta * y_damping_strength))
	
	parent.position = Vector2(new_x_position, new_y_position)
	
	return null

extends CameraState
class_name FollowState

var offset : float
var looking_left : bool
var starting_offset : float
var desired_offset : float

var new_x_position : float
var new_y_position : float

func enter() -> void:
	super()
	
	looking_left = parent.player.sprite.flip_h
	offset = stats.bias_length * (-1 if looking_left else 1)
	
func physics_update(delta : float) -> State:
	
	if looking_left != parent.player.sprite.flip_h:
		looking_left = parent.player.sprite.flip_h
		parent.timer_manager.set_timer("Bias turnaround", stats.bias_turnaround_time)
		starting_offset = offset
		desired_offset = stats.bias_length * (-1 if looking_left else 1)
	
	var time_left : float = parent.timer_manager.check_timer("Bias turnaround")
	
	if time_left > 0:
		var t = (stats.bias_turnaround_time - time_left) / stats.bias_turnaround_time
		offset = lerp(starting_offset, desired_offset, -(cos(PI * t) - 1) / 2)
	
	new_x_position = lerp(parent.position.x, parent.player.position.x + offset, 1 - exp(-delta * stats.x_damping_strength))
	
	if parent.player.position.y < parent.position.y:
		new_y_position = lerp(parent.position.y, parent.player.position.y, 1 - exp(-delta * stats.y_damping_strength_up))
	else:
		new_y_position = lerp(parent.position.y, parent.player.position.y, 1 - exp(-delta * stats.y_damping_strength_down))
	
	parent.position = Vector2(new_x_position, new_y_position)
	
	return null

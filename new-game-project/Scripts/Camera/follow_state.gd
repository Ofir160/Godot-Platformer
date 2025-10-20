extends CameraState
class_name FollowState

var offset : Vector2

func enter() -> void:
	super()
	
func physics_update(delta : float) -> State:
	
	if parent.player.sprite.flip_h:
		offset = Vector2(-stats.bias_length, 0)
	else:
		offset = Vector2(stats.bias_length, 0)
	
	var new_x_position : float = lerp(parent.position.x, parent.player.position.x + offset.x, 1 - exp(-delta * stats.x_damping_strength))
	var new_y_position : float = lerp(parent.position.y, parent.player.position.y, 1 - exp(-delta * stats.y_damping_strength))
	
	parent.position = Vector2(new_x_position, new_y_position)
	
	return null

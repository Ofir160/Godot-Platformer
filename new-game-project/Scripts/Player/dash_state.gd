extends PlayerState
class_name DashState

@export var dash_interruptable_state : PlayerState

var direction : Vector2
var time_started_dashing : float

func enter() -> void:
	super()
	
	PlayerState.dashes_available -= 1
	
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	if abs(direction.x) < 0.01 and abs(direction.y) < 0.01:
		direction.x = -1 if parent.animated_sprite.flip_h else 1
	
	parent.body.velocity = direction * stats.dash_length / stats.dash_time
	time_dashed = parent.current_time
	
func physics_update(delta : float) -> State:
	if parent.current_time - time_dashed > stats.dash_time * stats.dash_uninterruptable_percent:
		return dash_interruptable_state
		
	parent.body.move_and_slide()
	return null

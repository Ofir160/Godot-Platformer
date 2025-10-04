extends PlayerState
class_name DashInterruptableState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var slide_state : PlayerState

var time_started_slowing_down : float
var dash_time : float

func enter() -> void:
	super()
	
	time_started_slowing_down = parent.current_time
	dash_time = stats.dash_time * (1 - stats.dash_uninterruptable_percent)
	
func physics_update(delta : float) -> State:
	print(parent.body.velocity)
	if parent.body.is_on_floor():
		if abs(parent.body.velocity.x) < 0.01:
			return move_state
	if parent.body.is_on_wall():
		if abs(parent.body.velocity.y) < 0.01:
			return slide_state
	if parent.body.is_on_ceiling():
		if abs(parent.body.velocity.x) < 0.01:
			return air_state
				
	if parent.current_time - time_started_slowing_down > dash_time:
		if parent.body.is_on_floor():
			return move_state
		else:
			parent.body.velocity *= stats.dash_upwards_mult
			return air_state
	
	parent.body.move_and_slide()
	return null

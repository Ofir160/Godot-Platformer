extends PlayerState
class_name AttackState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var slide_state : PlayerState

var time_started : float

func enter() -> void:
	super()
	
	# Sets the dash start timer
	parent.timer_manager.set_timer("Attack", stats.interruptable_attack_time)
	
func process_input() -> State:
	
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Attack"):
		# End attack
		if parent.body.is_on_wall():
			return slide_state
		elif parent.body.is_on_floor():
			return move_state
		else:
			return air_state
		
	return null

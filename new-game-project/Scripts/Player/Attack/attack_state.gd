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
	
	# Sets the attack visuals
	parent.attack.attack(PlayerState.attack_direction)
	
func process_input() -> State:
	
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Attack"):
		# Hide the attack visuals
		parent.attack.retract()
		
		parent.body.velocity = PlayerState.saved_attack_speed * stats.attack_velocity_end_damping
		
		# End attack
		if parent.collision.is_on_wall(true):
			return slide_state
		elif parent.collision.is_on_floor(true):
			return move_state
		else:
			return air_state
		
	return null

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
	
	# During the attack make sure the player isn't moving in the wrong direction
	
	if wrong_y_velocity():
		print("Wrong Y")
		parent.body.velocity.y *= stats.wrong_y_velocity_penalty
			
	if wrong_x_velocity():
		print("Wrong X")
		parent.body.velocity.x *= stats.wrong_x_velocity_penalty
		
	# During the attack give bonuses if the player is moving in the right direction
	
	if right_x_velocity():
		print("Right X")
		
	if right_y_velocity():
		print("Right Y")
	
func process_input() -> State:
	
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Attack"):
		# Hide the attack visuals
		parent.attack.retract()
		
		parent.body.velocity = PlayerState.saved_attack_speed * stats.attack_velocity_end_damping
		
		# After the attack make sure the player isn't moving in the wrong direction
		
		if wrong_y_velocity():
			parent.body.velocity.y *= stats.wrong_y_velocity_penalty
			
		if wrong_x_velocity():
			parent.body.velocity.x *= stats.wrong_x_velocity_penalty
		
		parent.timer_manager.set_timer("Attack cooldown", stats.attack_cooldown)
		
		# End attack
		if parent.collision.is_on_wall(true):
			return slide_state
		elif parent.collision.is_on_floor(true):
			return move_state
		else:
			return air_state
		
	return null
	
## Checks if the player's y direction is not the same as the attack's y direction
func wrong_y_velocity() -> bool:
	return ((PlayerState.attack_direction.y > 0.01 and parent.body.velocity.y < -0.01)
	 or (PlayerState.attack_direction.y < -0.01 and parent.body.velocity.y > 0.01))
	
## Checks if the player's x direction is not the same as the attack's x direction
func wrong_x_velocity() -> bool:
	return ((PlayerState.attack_direction.x > 0.01 and parent.body.velocity.x < -0.01)
	 or (PlayerState.attack_direction.x < -0.01 and parent.body.velocity.x > 0.01))
	
## Checks if the player's x direction is the same as the attack's x direction
func right_x_velocity() -> bool:
	return ((PlayerState.attack_direction.x > 0.01 and parent.body.velocity.x > 0.01) 
	or (PlayerState.attack_direction.x < -0.01 and parent.body.velocity.x < -0.01)
	or (abs(PlayerState.attack_direction.x) < 0.01 and abs(parent.body.velocity.x) < 0.01))
	
## Checks if the player's y direction is the same as the attack's y direction
func right_y_velocity() -> bool:
	return ((PlayerState.attack_direction.y > 0.01 and parent.body.velocity.y > 0.01) 
	or (PlayerState.attack_direction.y < -0.01 and parent.body.velocity.y < -0.01)
	or (abs(PlayerState.attack_direction.y) < 0.01 and abs(parent.body.velocity.y) < 0.01))

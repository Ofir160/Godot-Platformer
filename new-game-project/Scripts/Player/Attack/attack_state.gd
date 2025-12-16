extends PlayerState
class_name AttackState

@export var air_state : PlayerState
@export var move_state : PlayerState
@export var slide_state : PlayerState

var time_started : float
var level : int

func enter() -> void:
	super()
	
	# Sets the dash start timer
	parent.timer_manager.set_timer("Attack", stats.interruptable_attack_time)
	
	# During the attack make sure the player isn't moving in the wrong direction
	
	var right_y : bool = right_y_velocity()
	var right_x : bool = right_x_velocity()
	
	var level_3 : bool = level_3_attack(right_x, right_y)
	var level_2 : bool = level_2_attack(right_x, right_y)
	
	if not right_y:
		parent.body.velocity.y *= stats.wrong_y_velocity_penalty
			
	if not right_x:
		parent.body.velocity.x *= stats.wrong_x_velocity_penalty
	
	# Dampens current velocity
	parent.body.velocity *= stats.attack_velocity_damping
	
	if level_3:
		print("Super Attack!")
		
		parent.body.velocity += PlayerState.attack_direction * stats.level_3_boost
		#parent.body.velocity *= stats.level_3_attack_mult
		level = 3
	elif level_2:
		print("Level 2 Attack!")
		
		parent.body.velocity += PlayerState.attack_direction * stats.level_2_boost
		#parent.body.velocity *= stats.level_2_attack_mult
		level = 2
	else:
		print("Basic Attack.")
		level = 1
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
		
		# After the attack make sure the player isn't moving in the wrong direction
		
		if not right_y_velocity():
			parent.body.velocity.y *= stats.wrong_y_velocity_penalty
			
		if not right_x_velocity():
			parent.body.velocity.x *= stats.wrong_x_velocity_penalty
		
		# After the attack give bonuses if the player is moving in the right direction
		match level:
			3:
				pass#parent.body.velocity += PlayerState.attack_direction * stats.level_3_boost
			2:
				pass#parent.body.velocity += PlayerState.attack_direction * stats.level_2_boost
			1:
				pass
		
		parent.timer_manager.set_timer("Attack cooldown", stats.attack_cooldown)
		
		# End attack
		if parent.collision.is_on_wall(true):
			return slide_state
		elif parent.collision.is_on_floor(true):
			return move_state
		else:
			return air_state
		
	return null
	
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
	
## Checks if the attack is fast enough to be a level 2 attack
func level_2_attack(right_x : bool, right_y : bool) -> bool:
	return ((right_x and right_y and parent.body.velocity.length() > stats.attack_level_2_threshold)
	or ((right_x or right_y) and parent.body.velocity.length() > stats.attack_level_3_threshold))
	
## Checks if the attack is fast enough to be a level 3 attack
func level_3_attack(right_x : bool, right_y : bool) -> bool:
	return (right_x and right_y and parent.body.velocity.length() > stats.attack_level_3_threshold)

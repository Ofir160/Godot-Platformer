extends PlayerState
class_name AttackStartState

@export var attack_state : PlayerState

var time_started : float
var direction : Vector2

func enter() -> void:
	super()
	
	# Sets the dash start timer
	parent.timer_manager.set_timer("Attack start", stats.frozen_attack_time)
	
	# Gets the direction the player would like to attack
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	# If the attack was done without moving set the direction to the way the character is facing
	if abs(direction.x) < 0.01 and abs(direction.y) < 0.01:
		direction.x = -1 if parent.sprite.flip_h else 1
		
	# Sets the attack direction to the desired direction
	PlayerState.attack_direction = direction
	
	# Saves starting velocity
	PlayerState.saved_attack_speed = parent.body.velocity
	
	# Dampens current velocity
	parent.body.velocity *= stats.attack_velocity_damping
	
func process_input() -> State:
	
	var new_direction : Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("look_up", "look_down")).normalized()
	
	if (new_direction - direction).length() > 0.01 and (abs(new_direction.x) > 0.01 or abs(new_direction.y) > 0.01):
		direction = new_direction
		
		# Flips character depending on movement direction
		if new_direction.x > 0:
			parent.sprite.flip_h = false
		elif new_direction.x < 0:
			parent.sprite.flip_h = true
		
		# Sets the attack direction to the desired direction
		PlayerState.attack_direction = direction
	
	return null
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	
	if parent.timer_manager.query_timer("Attack start"):
		return attack_state
		
	return null

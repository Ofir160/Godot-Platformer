extends PlayerState
class_name SuperDashState

@export var air_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	# Dampens vertical momentum
	parent.body.velocity.y *= stats.superdash_vertical_damping
	
	# Dampens horizontal momentum
	parent.body.velocity.x *= stats.superdash_horizontal_damping
	
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# When super dashing increase force
	if abs(PlayerState.dash_direction.y) > 0.01 and abs(PlayerState.dash_direction.x) > 0.01:
		# If doing a down superdash
		parent.body.velocity.y -= stats.superdash_down_force.y
		if abs(move_input) > 0.01:
			if sign(move_input) != sign(parent.body.velocity.x):
				parent.body.velocity.x = stats.superdash_down_force.x * sign(move_input) * stats.superdash_neck_snap_mult
			else:
				parent.body.velocity.x += stats.superdash_down_force.x * sign(move_input)
		else:
			parent.body.velocity.x += stats.superdash_down_force.x * (-1 if parent.sprite.flip_h else 1)
	elif abs(PlayerState.dash_direction.y) < 0.01:
		# If doing a straight superdash
		parent.body.velocity.y -= stats.superdash_straight_force.y
		if abs(move_input) > 0.01:
			if sign(move_input) != sign(parent.body.velocity.x):
				parent.body.velocity.x = stats.superdash_straight_force.x * sign(move_input) * stats.superdash_neck_snap_mult
			else:
				parent.body.velocity.x += stats.superdash_straight_force.x * sign(move_input)
		else:
			parent.body.velocity.x += stats.superdash_straight_force.x * (-1 if parent.sprite.flip_h else 1)
	
	# Sets the jump cooldown timer
	parent.timer_manager.set_timer("Jump cooldown", stats.jump_cooldown)
	
	# Consumes the superdash
	PlayerState.superdash_queued = false
	
	# Regain double jump
	PlayerState.double_jump_available = true
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state

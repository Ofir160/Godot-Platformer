extends PlayerState
class_name SuperDoubleJumpState

@export var air_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	# Dampens vertical momentum
	parent.body.velocity.y *= stats.super_double_jump_vertical_damping
	
	# Dampens horizontal momentum
	parent.body.velocity.x *= stats.super_double_jump_horizontal_damping
	
	if abs(PlayerState.dash_direction.x) < 0.01 and PlayerState.dash_direction.y < -0.01:
		# Super double jump upwards
		parent.body.velocity.y -= stats.super_double_up_force.y
	elif abs(PlayerState.dash_direction.x) > 0.01 and PlayerState.dash_direction.y < -0.01:
		# Super double jump up diagonally
		parent.body.velocity.y -= stats.super_double_up_diagonal_force.y
		
		if abs(move_input) > 0.01:
			if sign(move_input) != sign(parent.body.velocity.x):
				parent.body.velocity.x = stats.super_double_up_diagonal_force.x * sign(move_input) * stats.superdash_neck_snap_mult
			else:
				parent.body.velocity.x += stats.super_double_up_diagonal_force.x * sign(move_input)
		else:
			parent.body.velocity.x += stats.super_double_up_diagonal_force.x * (-1 if parent.animated_sprite.flip_h else 1)
	elif abs(PlayerState.dash_direction.x) > 0.01 and abs(PlayerState.dash_direction.y) < 0.01:
		# Super double jump straight
		parent.body.velocity.y -= stats.super_double_straight_force.y
		if abs(move_input) > 0.01:
			if sign(move_input) != sign(parent.body.velocity.x):
				parent.body.velocity.x = stats.super_double_straight_force.x * sign(move_input) * stats.superdash_neck_snap_mult
			else:
				parent.body.velocity.x += stats.super_double_straight_force.x * sign(move_input)
		else:
			parent.body.velocity.x += stats.super_double_straight_force.x * (-1 if parent.animated_sprite.flip_h else 1)
	elif abs(PlayerState.dash_direction.x) > 0.01 and PlayerState.dash_direction.y > 0.01:
		# Super double jump down diagonally
		parent.body.velocity.y -= stats.super_double_down_diagonal_force.y
		if abs(move_input) > 0.01:
			if sign(move_input) != sign(parent.body.velocity.x):
				parent.body.velocity.x = stats.super_double_down_diagonal_force.x * sign(move_input) * stats.superdash_neck_snap_mult
			else:
				parent.body.velocity.x += stats.super_double_down_diagonal_force.x * sign(move_input)
		else:
			parent.body.velocity.x += stats.super_double_down_diagonal_force.x * (-1 if parent.animated_sprite.flip_h else 1)
	else:
		# Cancel jump
		parent.body.velocity.y -= stats.jump_force
	
	# Sets the jump cooldown timer
	parent.timer_manager.set_timer("Jump cooldown", stats.jump_cooldown)
	
	# Consumes the superdash
	PlayerState.superdash_queued = false
	
	# Consumes the double jump
	PlayerState.double_jump_available = false
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state

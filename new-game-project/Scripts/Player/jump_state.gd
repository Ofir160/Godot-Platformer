extends PlayerState
class_name JumpState

@export var air_state : PlayerState
@export var dash_interruptable_state : PlayerState

func enter() -> void:
	super()
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	# Dampens horizontal momentum
	parent.body.velocity.x *= stats.jump_velocity_damping
	
	if previous_state == dash_interruptable_state or superdash_buffer_available():
		# When super dashing increase force
		
		# Gets the player's movement direction
		var move_input : float = Input.get_axis("move_left", "move_right")
		
		if PlayerState.double_jump_available:
			if abs(PlayerState.dash_direction.y) > 0.01 and abs(PlayerState.dash_direction.x) > 0.01:
				# If doing a down superdash
				parent.body.velocity.y -= stats.superdash_down_force.y
				if abs(move_input) > 0.01:
					if sign(move_input) != sign(parent.body.velocity.x):
						parent.body.velocity.x = stats.superdash_down_force.x * sign(move_input) * stats.superdash_neck_snap_mult
					else:
						parent.body.velocity.x += stats.superdash_down_force.x * sign(move_input)
				else:
					parent.body.velocity.x += stats.superdash_down_force.x * (-1 if parent.animated_sprite.flip_h else 1)
			elif abs(PlayerState.dash_direction.y) < 0.01:
				# If doing a straight superdash
				parent.body.velocity.y -= stats.superdash_force.y
				if abs(move_input) > 0.01:
					if sign(move_input) != sign(parent.body.velocity.x):
						parent.body.velocity.x = stats.superdash_force.x * sign(move_input) * stats.superdash_neck_snap_mult
					else:
						parent.body.velocity.x += stats.superdash_force.x * sign(move_input)
				else:
					parent.body.velocity.x += stats.superdash_force.x * (-1 if parent.animated_sprite.flip_h else 1)
	elif previous_state == air_state:
		# When double jumping reduce previous upward momentum
		parent.body.velocity.y *= 0.3
		parent.body.velocity.y -= stats.double_jump_force
	else:
		# Adds the jump force to the player
		parent.body.velocity.y -= stats.jump_force
	
	# Sets the time jumped to the current time
	PlayerState.time_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state
	
func superdash_buffer_available() -> bool:
	return (parent.current_time - PlayerState.time_dashed < stats.superdash_buffer_time and PlayerState.time_dashed > 0)

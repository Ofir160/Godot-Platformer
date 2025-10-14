extends PlayerState
class_name JumpState

@export var air_state : PlayerState
@export var dash_interruptable_state : PlayerState

var move_input : float

func enter() -> void:
	super()
	
	# Gets the player's movement direction
	move_input = Input.get_axis("move_left", "move_right")
	
	# Makes sure the player is not falling
	parent.body.velocity.y = min(parent.body.velocity.y, 0)
	
	if previous_state == dash_interruptable_state or superdash_buffer_available():
		# Dampens horizontal momentum
		parent.body.velocity.x *= stats.jump_velocity_damping
		
		# When super dashing increase force
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
		else:
			if abs(PlayerState.dash_direction.x) < 0.01 and PlayerState.dash_direction.y < -0.01:
				# Super double jump upwards
				print("Upwards")
				parent.body.velocity.y -= stats.super_double_up_force.y
			elif abs(PlayerState.dash_direction.x) > 0.01 and PlayerState.dash_direction.y < -0.01:
				# Super double jump up diagonally
				print("Up diagonal")
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
				print("Straight")
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
				print("Down diagonal")
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
	elif previous_state == air_state:
		# When double jumping reduce previous upward momentum
		parent.body.velocity.y *= 0.3
		parent.body.velocity.y -= stats.double_jump_force
		
		if not is_speeding(move_input):
			# Dampens horizontal momentum
			parent.body.velocity.x *= stats.jump_velocity_damping
		else:
			# Boosts horizontal speed
			parent.body.velocity.x *= stats.double_jump_velocity_boost
		
	else:
		# Dampens horizontal momentum
		parent.body.velocity.x *= stats.jump_velocity_damping
		
		# Adds the jump force to the player
		parent.body.velocity.y -= stats.jump_force
	
	# Sets the time jumped to the current time
	PlayerState.time_jumped = parent.current_time
	
func physics_update(delta : float) -> State:
	parent.body.move_and_slide()
	return air_state
	
func superdash_buffer_available() -> bool:
	return (parent.current_time - PlayerState.time_dashed < stats.superdash_buffer_time and PlayerState.time_dashed > 0)
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > stats.max_speed and sign(parent.body.velocity.x) == sign(input) and abs(input) > 0.01

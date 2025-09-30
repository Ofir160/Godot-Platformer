extends PlayerState
class_name IdleState

@export var jump_state : PlayerState
@export var move_state : PlayerState
@export var air_state : PlayerState

func enter(previous_state : State) -> void:
	super(previous_state)
	parent.body.velocity.x = 0.0
	
func process_input() -> State:
	# Check if any jumps were queued or if the jump button is pressed
	if is_jump_buffered() and is_grounded():
		return jump_state
		
	# Checks for player movement
	if Input.get_axis("move_left", "move_right") != 0:
		return move_state
	
	
	return null

func physics_update(delta : float) -> State:
	# Checks if the player becomes in the air
	if not parent.body.is_on_floor():
		return air_state
	
	parent.move_and_slide()
	return null

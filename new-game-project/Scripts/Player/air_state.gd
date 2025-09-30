extends PlayerState
class_name AirState

@export var move_state : PlayerState
@export var idle_state : PlayerState
@export var jump_state : PlayerState

var move_input : float

func enter(previous_state : State) -> void:
	super(previous_state)
	
func process_input() -> State:
	move_input = Input.get_axis("move_left", "move_right")
	
	if move_input > 0:
		parent.animated_sprite.flip_h = false
	elif move_input < 0:
		parent.animated_sprite.flip_h = true
	
	return null

func physics_update(delta : float) -> State:
	# Checks if the player becomes in the air
	if not parent.body.is_on_floor():
		return air_state
	
	parent.move_and_slide()
	return null

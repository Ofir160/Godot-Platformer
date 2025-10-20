class_name PlayerState
extends State

@export var animation_name : String
@export var stats : PlayerStats

static var double_jump_available : bool

static var dashes_available : int
static var dash_direction : Vector2
static var superdash_queued : bool
<<<<<<< HEAD

func enter() -> void:
	super()
	parent.animated_sprite.play(animation_name)
=======
>>>>>>> 229028fd398494695161919295fadf3a851ab744

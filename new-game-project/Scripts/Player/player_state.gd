class_name PlayerState
extends State

@export var animation_name : String
@export var stats : PlayerStats

static var double_jump_available : bool

static var dashes_available : int
static var dash_direction : Vector2
static var superdash_queued : bool

static var saved_dash_speed : float

func enter() -> void:
	super()
	parent.sprite.play(animation_name)

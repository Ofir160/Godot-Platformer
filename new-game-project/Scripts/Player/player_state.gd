class_name PlayerState
extends State

@export var animation_name : String
@export var stats : PlayerStats

static var double_jump_available : bool

static var dash_direction : Vector2
static var saved_dash_speed : float
static var dashes_available : int
static var superdash_queued : bool

static var attack_direction : Vector2
static var saved_attack_speed : Vector2

func enter() -> void:
	super()
	parent.sprite.play(animation_name)

class_name PlayerState
extends State

@export var stats : PlayerStats

static var time_jumped : float
static var time_wall_jumped : float
static var time_dashed : float

static var dashes_available : int
static var dash_direction : Vector2
static var double_jump_available : bool
static var superdash_queued : bool

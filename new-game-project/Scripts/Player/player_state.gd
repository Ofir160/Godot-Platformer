class_name PlayerState
extends State

@export var move_speed : float = 250.0
@export var max_speed : float = 275.0
@export var max_fall_speed : float = 1000
@export var acceleration : float = 30
@export var deceleration : float = 20
@export var air_acceleration_mult : float = 0.2
@export var air_deceleration_mult : float = 0.3
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.1
@export var jump_cooldown : float = 0.5
@export var jump_force : float = 600
@export var jump_hang_time_threshold : float = 50
@export var jump_apex_acceleration_mult : float = 1.2
@export var jump_apex_speed_mult : float = 1.1
@export var jump_release_gravity_mult : float = 1.75
@export var jump_fall_gravity_mult : float = 1.25
@export var jump_apex_gravity_mult : float = 0.75
@export var initial_gravity : float = 1200

var time_left_ground : float
var time_jump_pressed : float
var time_jumped : float
var current_time : float 
var accel_rate : float

var grounded : bool
var jumping : bool

func is_grounded() -> bool:
	return grounded or current_time - time_left_ground < coyote_time
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (current_time - time_jump_pressed < jump_buffer_time and time_jump_pressed > 0)) and current_time - time_jumped > jump_cooldown
	
func is_speeding(input : float) -> bool:
	return abs(parent.body.velocity.x) > max_speed and sign(parent.body.velocity.x) == sign(input) and input > 0.01
	
func is_at_apex() -> bool:
	return jumping and abs(parent.body.velocity.y) < jump_hang_time_threshold

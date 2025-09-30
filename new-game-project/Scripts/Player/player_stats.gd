class_name PlayerStats
extends Resource

@export var move_speed : float = 250.0
@export var max_speed : float = 275.0
@export var max_fall_speed : float = 1000
@export var acceleration : float = 30
@export var deceleration : float = 20
@export var air_acceleration_mult : float = 0.2
@export var air_deceleration_mult : float = 0.3
@export var jump_force : float = 600
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.1
@export var jump_cooldown : float = 0.5
@export var jump_hang_time_threshold : float = 50
@export var jump_apex_acceleration_mult : float = 1.2
@export var jump_apex_speed_mult : float = 1.1
@export var jump_release_gravity_mult : float = 1.75
@export var jump_fall_gravity_mult : float = 1.25
@export var jump_apex_gravity_mult : float = 0.75
@export var initial_gravity : float = 1200

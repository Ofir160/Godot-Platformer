class_name PlayerStats
extends Resource

@export_category("Movement Stats")
@export var move_speed : float = 300.0
@export var max_speed : float = 325.0
@export var max_fall_speed : float = 1000
@export var acceleration : float = 25
@export var deceleration : float = 10
@export var speeding_deceleration : float = 3
@export var air_acceleration_mult : float = 0.3
@export var air_deceleration_mult : float = 0.3
@export_category("Jump Stats")
@export var jump_force : float = 600
@export var double_jump_force : float = 500
@export var coyote_time : float = 0.1
@export var jump_buffer_time : float = 0.1
@export var jump_cooldown : float = 0.5
@export var jump_velocity_damping : float = 0.2
@export var double_jump_velocity_boost : float = 1.25
@export var jump_hang_time_threshold : float = 50
@export var jump_apex_acceleration_mult : float = 1.2
@export var jump_apex_speed_mult : float = 1.1
@export var jump_release_gravity_mult : float = 1.9
@export var jump_fall_gravity_mult : float = 1.25
@export var jump_apex_gravity_mult : float = 0.8
@export var double_jump_gravity_mult : float = 0.8
@export var initial_gravity : float = 1300
@export_category("Wall Stats")
@export var slide_speed : float = 350
@export var slide_acceleration : float = 4.0
@export var wall_jump_cooldown : float = 0.4
@export var wall_jump_buffer_time : float = 0.2
@export var wall_jump_up_velocity_threshold : float = 200
@export var wall_jump_velocity_damping : float = 0.2
@export var wall_jump_force : Vector2 = Vector2(375, 600)
@export var wall_jump_release_gravity_mult : float = 2.1
@export var wall_jump_back_mult : float = 1.1
@export var wall_jump_move_back_mult : float = 1.2
@export var wall_jump_damping_time : float = 0.25
@export var wall_jump_damping_strength : float = 0.3
@export_category("Dash Stats")
@export var dashes : int = 1
@export var dash_cooldown : float = 0.25
@export var dash_length : float = 150
@export var dash_time : float = 0.2
@export var dash_frozen_percent : float = 0.2
@export var dash_regain_percent : float = 0.6
@export var dash_damping_mult : float = 0.3
@export var dash_upwards_mult : float = 0.55
@export var dash_downwards_mult : float = 1.1
@export var dash_horizontal_mult : float = 0.6

var frozen_dash_time : float:
	get:
		return dash_time * dash_frozen_percent
var interruptable_dash_time : float:
	get:
		return dash_time * (1 - dash_frozen_percent)
var regain_dash_time : float:
	get:
		return interruptable_dash_time * dash_regain_percent

@export_category("Superdash Stats")
@export var superdash_buffer_time : float = 0.2
@export var superdash_neck_snap_mult : float = 1.5
@export var superdash_down_force : Vector2 = Vector2(1000, 450)
@export var superdash_force : Vector2 = Vector2(800, 600)
@export var superdash_wall_up_force : Vector2 = Vector2(200, 750)
@export var superdash_wall_diagonal_force : Vector2 = Vector2(450, 600)
@export var superdash_wall_straight_force : Vector2 = Vector2(600, 600)
@export_category("Super Double Jump")
@export var super_double_up_force : Vector2 = Vector2(0, 400)
@export var super_double_up_diagonal_force : Vector2 = Vector2(400, 400)
@export var super_double_straight_force : Vector2 = Vector2(700, 500)
@export var super_double_down_diagonal_force : Vector2 = Vector2(800, 500)

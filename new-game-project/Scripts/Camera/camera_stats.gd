class_name CameraStats
extends Resource

@export_category("Damping Strength")
@export var x_damping_strength : float = 2.0
@export var y_damping_strength_up : float = 5.3
@export var y_damping_strength_down : float = 10.0
@export var y_damping_change_time : float = 0.35
@export var y_damping_change_velocity_threshold : float = 100

@export_category("Bias")
@export var bias_length : float = 75
@export var bias_turnaround_time : float = 0.4

@export_category("Lookahead")
@export var lookahead_time : float = 0.05

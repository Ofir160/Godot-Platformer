extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite2D

@export var move_speed : float
@export var max_speed : float
@export var max_fall_speed : float
@export var acceleration : float
@export var deceleration : float
@export var air_acceleration_mult : float
@export var air_deceleration_mult : float
@export var coyote_time : float
@export var jump_buffer_time : float
@export var jump_cooldown : float
@export var jump_force : float
@export var jump_hang_time_threshold : float
@export var jump_apex_acceleration_mult : float
@export var jump_apex_speed_mult : float
@export var jump_release_gravity_mult : float
@export var jump_fall_gravity_mult : float
@export var jump_apex_gravity_mult : float
@export var initial_gravity : float

var time_left_ground : float
var time_jump_pressed : float
var time_jumped : float
var current_time : float 
var accel_rate : float

var grounded : bool
var jumping : bool

func _physics_process(delta: float) -> void:
	check_grounded()
	check_jumped()
	apply_gravity(delta)
	apply_jump_force(delta)
	apply_movement(delta)
	
	move_and_slide()
	
	current_time += delta

func check_grounded() -> void:
	var new_grounded = is_on_floor()
	
	if grounded and not new_grounded:
		time_left_ground = current_time
		
	if new_grounded:
		jumping = false
		
	grounded = new_grounded
	
func check_jumped() -> void:
	if Input.is_action_just_pressed("jump"):
		time_jump_pressed = current_time

func apply_movement(delta : float) -> void:
	var input = Input.get_axis("move_left", "move_right")
	var target_speed = input * move_speed
	
	if not is_speeding(input):
		accel_rate = acceleration if abs(target_speed) > 0.01 else deceleration
		if not is_grounded():
			if is_at_apex():
				accel_rate *= jump_apex_acceleration_mult
				target_speed *= jump_apex_speed_mult
			
			accel_rate *= air_acceleration_mult if abs(target_speed) > 0.01 else air_deceleration_mult
	else:
		accel_rate = 0
	
	if abs(target_speed) > 0.01:
		sprite.play("move")
	else:
		sprite.play("idle")
		
	if target_speed < 0:
		sprite.flip_h = true
	elif target_speed > 0:
		sprite.flip_h = false
	
	var movement = (target_speed - velocity.x) * accel_rate
	
	velocity.x += movement * delta
	
func apply_gravity(delta : float) -> void:
	
	var gravity = initial_gravity
	
	if not grounded:
		if jumping:
			if is_at_apex():
				gravity *= jump_apex_gravity_mult
			if not Input.is_action_pressed("jump"):
				gravity *= jump_release_gravity_mult
			elif velocity.y > 0:
				gravity *= jump_fall_gravity_mult
		velocity.y += gravity * delta
		velocity.y= min(velocity.y, max_fall_speed)
		
func apply_jump_force(delta : float) -> void:
	if is_grounded() and is_jump_buffered():
		velocity.y = min(velocity.y, 0)
		velocity.y -= jump_force
		jumping = true
		time_jumped = current_time
	
func is_grounded() -> bool:
	return grounded or current_time - time_left_ground < coyote_time
	
func is_jump_buffered() -> bool:
	return (Input.is_action_just_pressed("jump") or (current_time - time_jump_pressed < jump_buffer_time and time_jump_pressed > 0)) and current_time - time_jumped > jump_cooldown
	
func is_speeding(input : float) -> bool:
	return abs(velocity.x) > max_speed and sign(velocity.x) == sign(input) and input > 0.01
	
func is_at_apex() -> bool:
	return jumping and abs(velocity.y) < jump_hang_time_threshold

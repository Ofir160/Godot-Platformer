extends Node
class_name AttackManager

@export var normal_right : AnimatedSprite2D
@export var normal_left : AnimatedSprite2D
@export var normal_up : AnimatedSprite2D
@export var normal_down : AnimatedSprite2D
@export var normal_down_right : AnimatedSprite2D
@export var normal_down_left : AnimatedSprite2D
@export var normal_up_right : AnimatedSprite2D
@export var normal_up_left : AnimatedSprite2D

var attack_direction : Vector2

func attack(direction : Vector2) -> void:
	attack_direction = direction
	
	var sprite : AnimatedSprite2D = convert_direction(direction)
	
	if sprite != null:
		sprite.play("Attack")
	
func retract() -> void:
	var sprite : AnimatedSprite2D = convert_direction(attack_direction)
	
	if sprite != null:
		sprite.play("Hide")

func convert_direction(direction : Vector2) -> AnimatedSprite2D:
	# If attacking vertically
	if abs(direction.x) < 0.01:
		if abs(direction.y) < 0.01:
			return null
		elif direction.y > 0.01:
			return normal_down
		else:
			return normal_up 
	# If attacking right
	elif direction.x > 0:
		if abs(direction.y) < 0.01:
			return normal_right
		elif direction.y > 0.01:
			return normal_down_right
		else:
			return normal_up_right
	# If attacking left
	else:
		if abs(direction.y) < 0.01:
			return normal_left
		elif direction.y > 0.01:
			return normal_down_left
		else:
			return normal_up_left

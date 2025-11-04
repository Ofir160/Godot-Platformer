extends Node
class_name RaycastManager

@export var near_right : RayCast2D
@export var near_left : RayCast2D
@export var near_up : RayCast2D
@export var near_down : RayCast2D
@export var far_right : RayCast2D
@export var far_left : RayCast2D
@export var far_up : RayCast2D
@export var far_down : RayCast2D

## Returns true if the character is on the wall or false if not. Pass in true to use near raycasts, false for far raycasts.
func is_on_wall(near : bool) -> bool:
	if near:
		return near_right.is_colliding() or near_left.is_colliding()
	else:
		return far_right.is_colliding() or far_left.is_colliding()

## Returns true if the character is on the floor or false if not. Pass in true to use near raycasts, false for far raycasts.
func is_on_floor(near : bool) -> bool:
	if near:
		return near_down.is_colliding()
	else:
		return far_down.is_colliding()
		
## Returns true if the character is touching the cieling or false if not. Pass in true to use near raycasts, false for far raycasts.
func is_on_cieling(near : bool) -> bool:
	if near:
		return near_up.is_colliding()
	else:
		return far_up.is_colliding()

## Returns 1 if touching left wall, -1 if touching right wall and 0 if not touching a wall
func get_wall_side() -> int:
	if far_left.is_colliding():
		return 1
	elif far_right.is_colliding():
		return -1
	else:
		return 0

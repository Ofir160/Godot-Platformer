extends Node
class_name State

@export var animation_name : String
var parent : Parent

func enter(previous_state : State) -> void:
	parent.animated_sprite.play(animation_name)

func exit() -> void:
	pass
	
func process_input() -> State:
	return null
	
func physics_update(delta : float) -> State:
	return null

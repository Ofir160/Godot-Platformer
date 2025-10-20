extends Node
class_name State

var parent : Parent
var previous_state : State

func enter() -> void:
	if parent.print_state_changes:
		print("State change! Went from " + (str(previous_state.name) if previous_state else "nothing") + " to " + str(name))

func exit() -> void:
	pass
	
func process_input() -> State:
	return null
	
func physics_update(delta : float) -> State:
	return null

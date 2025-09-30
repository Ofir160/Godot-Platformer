class_name StateMachine
extends Node

@export var initial_state : State

var current_state : State

func init(parent : Parent) -> void:
	for child in get_children():
		if child is State:
			child.parent = parent # Sets the states parent to the parent
			
	if initial_state:
		initial_state.enter() # Enters the initial state
		current_state = initial_state

func handle_input() -> void:
	if current_state:
		var new_state = current_state.process_input() # Process the frames input
		if new_state:
			change_state(new_state) # Changes state if necessary
			
func physics_process(delta: float) -> void:
	if current_state:
		var new_state = current_state.physics_update(delta) # Updates the parent
		if new_state != null:
			change_state(new_state) # Changes state if necessary

func change_state(new_state : State) -> void:
	if !new_state:
		return
	
	if current_state:
		current_state.exit() # Exits old state
	
	new_state.previous_state = current_state
	new_state.enter() # Enters new state
	current_state = new_state

extends Node
class_name Parent

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $"State Machine"

var current_time : float

func _ready() -> void:
	state_machine.init(self)
	
func _physics_process(delta: float) -> void:
	current_time += delta
	
	state_machine.handle_input()
	state_machine.physics_process(delta)

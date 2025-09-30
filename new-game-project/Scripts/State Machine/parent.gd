extends Node
class_name Parent

#@onready var time_system: Node = %TimeSystem
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $"State Machine"

func _ready() -> void:
	state_machine.init(self)
	
func _physics_process(delta: float) -> void:
	state_machine.handle_input()
	state_machine.physics_process(delta)

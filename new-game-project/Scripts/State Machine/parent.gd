extends Node
class_name Parent

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $"State Machine"
@onready var timer_manager: TimerManager = $"Timer Manager"

@export var print_state_changes : bool

var current_time : float

func _ready() -> void:
	state_machine.init(self)
	
func _physics_process(delta: float) -> void:
	current_time += delta
	
	timer_manager.update(delta)
	state_machine.handle_input()
	state_machine.physics_process(delta)

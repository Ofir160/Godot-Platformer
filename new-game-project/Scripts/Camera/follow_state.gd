extends State
class_name FollowState

func enter() -> void:
	super()
	
func physics_update(delta : float) -> State:
	
	parent.position = parent.player.position
	
	return null

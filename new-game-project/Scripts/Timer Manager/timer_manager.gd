class_name TimerManager
extends Node

var timers : Dictionary[String, float]

func update(delta : float) -> void:
	for timer in timers.keys():
		var new_time : float = timers.get(timer) - delta
		
		if new_time <= 0:
			timers.erase(timer)
		else:
			timers.set(timer, new_time)

## Sets the timer
func set_timer(name : String, duration : float) -> void:
	timers.set(name.to_upper(), duration)
	
## Checks if the timer is finished. Returns true if timer is finished or if it doesn't exist
func query_timer(name : String) -> bool:
	if timers.has(name.to_upper()):
		var time_left : float = timers.get(name.to_upper())
		
		if time_left <= 0:
			return true
		else:
			return false 
	else:
		return true

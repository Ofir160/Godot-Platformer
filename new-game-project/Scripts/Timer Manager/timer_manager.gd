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
	
## Queries if the timer is finished. Returns true if timer is finished or if it doesn't exist
func query_timer(name : String) -> bool:
	if timers.has(name.to_upper()):
		var time_left : float = timers.get(name.to_upper())
		
		if time_left <= 0:
			return true
		else:
			return false 
	else:
		return true
		
## Checks the time left on the timer. Returns 0 if the timer doesn't exist
func check_timer(name : String) -> float:
	if timers.has(name.to_upper()):
		return timers.get(name.to_upper())
	else:
		return 0
		
## Kills a timer. Does nothing if the timer doesn't exist
func kill_timer(name : String) -> void:
	if timers.has(name.to_upper()):
		timers.erase(name.to_upper())

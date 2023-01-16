var cooldown = 0.0
var action_time = 0.0
var time = 0

func _init(action_time,cooldown):
	self.cooldown = cooldown
	self.action_time = action_time
	self.time = 999
	
func tick(delta):
	time = time + delta

func is_ready():
	if time > action_time + cooldown:
		return true
	else :
		return false

func is_actionning():
	if time < action_time:
		return true
	else :
		return false

func action():
	if time > action_time + cooldown:
		time = 0
		return true
	else :
		return false

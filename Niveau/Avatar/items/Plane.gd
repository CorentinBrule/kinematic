@tool
extends Item

@export var infinite = true
@export var plane_time_max = 100
@export var plane_effect = 2

var plane_time = 0

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "A"
	keyboard_key_scancode = OS.find_keycode_from_string("a")
	has_effect = true
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"plane_time" : plane_time
	}

func process(delta):
	if action:
		progress_percent = (float(plane_time_max) - plane_time) / plane_time_max * 100
	else:
		progress_percent = 0

func physics_process(delta):
	if infinite and action:
		active()
	elif action and plane_time < plane_time_max:
			active()
			plane_time += 1
	
	#print(avatar.colle == true and avatar.is_on_wall())
	if avatar.is_on_floor() or avatar.is_on_wall() and avatar.colle == true:
		plane_time = 0

func active():
	if avatar.velocity.y < 0:
		avatar.velocity.y = 0
	else:
		avatar.velocity.y = avatar.velocity.y/plane_effect

@tool
extends Item

@export var infinite = true
@export var plane_time_max = 100
@export var plane_effect = 2

var plane_time = 0

var progress_percent

# Called when the node enters the scene tree for the first time.
func _ready():
	input_keyboard = OS.find_keycode_from_string("a")
	init_input(action_name, input_keyboard, input_xbox_map.find(xbox_button))
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"plane_time" : plane_time
	}
	
	progress_percent = 0
	

func process(delta):
	progress_percent = (float(plane_time_max) - plane_time) / plane_time_max * 100

func physics_process(delta):
	var action = Input.is_action_pressed(action_name)
	
	if infinite and action:
		action()
	elif action and plane_time < plane_time_max:
			action()
			plane_time += 1
	
	#print(avatar.colle == true and avatar.is_on_wall())
	if avatar.is_on_floor() or avatar.is_on_wall() and avatar.colle == true:
		plane_time = 0

func action():
	if avatar.velocity.y < 0:
		avatar.velocity.y = 0
	else:
		avatar.velocity.y = avatar.velocity.y/plane_effect

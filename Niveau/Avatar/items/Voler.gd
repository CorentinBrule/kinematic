@tool
extends Item

@export var infinite = true
@export var energy_max = 100
var energy = energy_max
@export var energy_use = 1.5
@export var energy_regen = 5
@export var jetpack_power = 10
@export var time_to_regen = 10
@export var maximum_vertical_speed = -110
var regen_time = 0

var progress_percent

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "F"
	keyboard_key_scancode = OS.find_keycode_from_string("f")
	progress_percent = 0
	initial_state = {
		"regen_time" : regen_time,
		"energy" : energy
	}

func process(delta):
	progress_percent = energy / energy_max * 100

func physics_process(delta):
	var action = Input.is_action_pressed(name)
	
	if action and infinite:
		action()
	elif action and energy > 0:
		regen_time = 0
		action()
		energy = max(min(energy_max, energy - energy_use), 0)
		
	else:
		if regen_time > time_to_regen:
			energy = max(min(energy_max, energy + energy_regen), 0)
		regen_time += 1

func action():
	avatar.velocity.y = max(avatar.velocity.y - jetpack_power, maximum_vertical_speed)

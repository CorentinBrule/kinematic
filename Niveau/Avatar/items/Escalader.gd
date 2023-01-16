@tool
extends Item

@export var glue_time_max = 10
@export var glue_effect = 1000
@export var glue_delay = 1
var colle_time = glue_time_max
var no_collision_count = 0
var no_wall_count = 0
# Called when the node enters the scene tree for the first time.

func _ready():
	input_keyboard = OS.find_keycode_from_string("e")
	init_input(action_name, input_keyboard, input_xbox_map.find(xbox_button))
	avatar = get_parent()
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"no_wall_count" : no_wall_count,
		"no_collision_count" : no_collision_count,
		"colle_time" : colle_time
	}

func physics_process(delta):
	var action = Input.is_action_pressed(action_name)
	
	if action:
		if avatar.is_on_wall():
			avatar.colle = true
			avatar.jumping = false

		if avatar.is_on_wall() == false:
			avatar.colle = false

	if Input.is_action_just_pressed("Sauter"):
		if avatar.colle:
			avatar.colle = false
			avatar.velocity.x = avatar.physic_direction * -100
	
	if avatar.colle:
		avatar.velocity.x = 0
		avatar.velocity.y /= glue_effect
		# reset air_time so reset jump
		avatar.on_air_time = 0

	if Input.is_action_just_released(action_name):
		avatar.colle = false


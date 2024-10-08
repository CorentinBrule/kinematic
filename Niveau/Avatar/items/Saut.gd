tool
extends Item

#var on_air_time = 100
export var jump_power =  200
const JUMP_MAX_AIRBORNE_TIME = 0.2

var prev_jump_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	keyboard_key_name = "space"
	keyboard_key_scancode = KEY_SPACE
	init()
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"prev_jump_pressed" : prev_jump_pressed
	}

func physics_process(delta):
	if avatar.is_on_floor():
		avatar.on_air_time = 0
		avatar.jumping = false

	if avatar.jumping and avatar.velocity.y > 0:
		# If falling, no longer jumping
		avatar.jumping = false
	
	if avatar.on_air_time < JUMP_MAX_AIRBORNE_TIME and action and not prev_jump_pressed and not avatar.jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		avatar.velocity.y -= jump_power
		
		if avatar.colle:
			avatar.colle = false
			avatar.velocity.x += -avatar.physic_direction*100

		avatar.jumping = true
	
	avatar.on_air_time += delta
	prev_jump_pressed = action

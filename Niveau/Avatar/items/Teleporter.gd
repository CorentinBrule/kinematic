@tool
extends Item

@export var tp_distance = 31
@export var tp_cooldown = 50
var recall

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "T"
	keyboard_key_scancode = OS.find_keycode_from_string("t")
	recall = tp_cooldown
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"recall" : recall
	}
	
func physics_process(delta):
	action = Input.is_action_pressed(name)
	
	if action and recall > tp_cooldown:
		if Input.is_action_pressed("move_left"):
			avatar.get_node("AnimationDéplacement").play("téléportation_gauche",-1,2,false)
			teleportation(-1)
		elif Input.is_action_pressed("move_right"):
			avatar.get_node("AnimationDéplacement").play("téléportation_droit",-1,2,false)
			teleportation(1)
		elif avatar.input_direction == 1:
			avatar.get_node("AnimationDéplacement").play("téléportation_droit",-1,2,false)
			teleportation(avatar.input_direction)
		elif avatar.input_direction == -1:
			avatar.get_node("AnimationDéplacement").play("téléportation_gauche",-1,2,false)
			teleportation(avatar.input_direction)
		recall = 0
	recall+=1

func teleportation(direction):
	avatar.old_pos = avatar.position
	avatar.position.x += direction * tp_distance

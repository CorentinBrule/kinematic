@tool
extends Item

@export var tp_distance = 31
@export var tp_cooldown = 50
var max_actions_per_jump = 1
var activated_for_jump = 0
var recall

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "Z"
	keyboard_key_scancode = OS.find_keycode_from_string("z")
	has_cooldown = true
	recall = tp_cooldown
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"recall" : recall
	}

func ready():
	cooldown_time = tp_cooldown * 1.0/60.0

func process(delta):
	cooldown_percent = (tp_cooldown - recall) / tp_cooldown * 100
	if activated_for_jump >= max_actions_per_jump:
		cooldown_percent = 100


func physics_process(delta):
	if avatar.is_on_floor():
		activated_for_jump = 0
	if action and recall > tp_cooldown and activated_for_jump < max_actions_per_jump:
		activated_for_jump += 1
		if Input.is_action_pressed("move_up"):
			avatar.get_node("AnimationDéplacement").play("téléportation_haut",-1,2,false)
			teleportation(-1)
		elif Input.is_action_pressed("move_bottom"):
			avatar.get_node("AnimationDéplacement").play("téléportation_bas",-1,2,false)
			teleportation(1)
		else:
			avatar.get_node("AnimationDéplacement").play("téléportation_haut",-1,2,false)
			teleportation(-1)
		recall = 0
	recall+=1

func teleportation(direction):
	avatar.old_pos = avatar.position
	avatar.position.y += direction * tp_distance

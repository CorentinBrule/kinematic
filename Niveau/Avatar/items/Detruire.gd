@tool
extends Item

@onready var animation = get_parent().get_node("AnimationInteraction")
@export var _effect_time:float = 0.5
@export var _cooldown_time:float = 0.2

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "D"
	keyboard_key_scancode = OS.find_keycode_from_string("d")
	has_cooldown = true
	has_effect = true
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"action": false
	}

func ready():
	# écraser les valeurs de Item depuis l'export de l'intsance de l'item
	effect_time = _effect_time
	cooldown_time = _cooldown_time

func process(delta):
	cooldown_percent = cooldown.time_left / cooldown.wait_time * 100
	progress_percent = effect.time_left / effect.wait_time * 100

func physics_process(delta):
	if action and cooldown.is_stopped() and effect.is_stopped():
		effect.start()
		#cooldown.action()
		animation.play("action", -1, 1.0 / effect_time,false)
	
	if effect.time_left > 0:
		action = true
		avatar.attacking = true
		avatar.get_node("Effet").color = avatar.colors_val[avatar.color_bonus]

func _on_Cooldown_timeout():
	avatar.get_node("Effet").color = Color(1,1,1,1)

func _on_Effect_timeout():
	avatar.attacking = false
	cooldown.start()
	avatar.get_node("Effet").color = Color(1,1,1,0)

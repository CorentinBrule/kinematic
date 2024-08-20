tool
extends Item

var animation

export var _effect_time = 0.5
export var _cooldown_time = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	keyboard_key_name = "P"
	keyboard_key_scancode = OS.find_scancode_from_string("p")
	has_cooldown = true
	has_effect = true
	effect_time = _effect_time
	init()
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
		"action" : false
	}
	
	animation = avatar.get_node("AnimationInteraction")

func process(delta):
	cooldown_percent = cooldown.time_left / cooldown.wait_time * 100
	progress_percent = effect.time_left / effect.wait_time * 100

func physics_process(delta):
	if action and cooldown.is_stopped() and effect.is_stopped() :
		effect.start()
		#print(1.0/effect_time) #replace 1.0 par la durée de l'animation
		animation.play("action",-1,1.0/effect_time,false)
		
	if effect.time_left > 0:
		action = true
		avatar.get_node("Effet").color = avatar.colors_val[avatar.color_malus]
		avatar.bouncing = true

func _on_Cooldown_timeout():
	avatar.get_node("Effet").color = Color(1,1,1,1)

func _on_Effect_timeout():
	avatar.bouncing = false
	cooldown.start()
	avatar.get_node("Effet").color = Color(1,1,1,0)
	

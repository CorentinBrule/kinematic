tool
extends Item
const Cooldown = preload('res://Niveau/Avatar/cooldown.gd')

var cooldown
var effect
var animation

export var effect_time = 0.5
export var cooldown_time = 0.2

var progress_percent = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	keyboard_key_name = "P"
	keyboard_key_scancode = OS.find_scancode_from_string("p")
	init()
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
	}
	
	cooldown = Cooldown.new(effect_time, cooldown_time)
	animation = avatar.get_node("AnimationInteraction")
	
	cooldown = Timer.new()
	add_child(cooldown)
	cooldown.wait_time = cooldown_time
	cooldown.one_shot = true
	cooldown.connect("timeout", self, "_on_Cooldown_timeout")
	
	effect = Timer.new()
	add_child(effect)
	effect.wait_time = effect_time
	effect.one_shot = true
	effect.connect("timeout", self, "_on_Effect_timeout")
	
func physics_process(delta):
	action = Input.is_action_just_pressed(action_name)
	
	progress_percent = effect.time_left / effect_time * 100
	
	if action and cooldown.is_stopped() and effect.is_stopped() :
		effect.start()
		print(1.0/effect_time) #replace 1.0 par la durée de l'animation
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
	

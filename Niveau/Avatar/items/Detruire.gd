@tool
extends Item
const Cooldown = preload('res://Niveau/Avatar/cooldown.gd')

var cooldown
var effect
@onready var animation = get_parent().get_node("AnimationInteraction")
@export var effect_time = 0.5
@export var cooldown_time = 0.2

# Called when the node enters the scene tree for the first time.
func _init():
	keyboard_key_name = "D"
	keyboard_key_scancode = OS.find_keycode_from_string("d")
	# noms de variables et leur valeur par défaut au reset
	initial_state = {
	}
	
	cooldown = Timer.new()
	add_child(cooldown)
	cooldown.wait_time = cooldown_time
	cooldown.one_shot = true
	cooldown.connect("timeout",Callable(self,"_on_Cooldown_timeout"))
	
	effect = Timer.new()
	add_child(effect)
	effect.wait_time = effect_time
	effect.one_shot = true
	effect.connect("timeout",Callable(self,"_on_Effect_timeout"))

func physics_process(delta):

	var action = Input.is_action_just_pressed(name)

	if action and cooldown.is_stopped() and effect.is_stopped():
		effect.start()
		#cooldown.action()
		animation.play("action", -1, 1.0 / effect_time,false)
	
	if effect.time_left > 0:
		avatar.attacking = true
		avatar.get_node("Effet").color = avatar.colors_val[avatar.color_bonus]	

func _on_Cooldown_timeout():
	avatar.get_node("Effet").color = Color(1,1,1,1)

func _on_Effect_timeout():
	avatar.attacking = false
	cooldown.start()
	avatar.get_node("Effet").color = Color(1,1,1,0)

extends Item
const Cooldown = preload('res://cooldown.gd')

var player
var cooldown
var animation
var effect_time
var cooldown_time

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	effect_time = 0.5
	cooldown_time = 0.1
	cooldown = Cooldown.new(effect_time,cooldown_time)
	animation = player.get_node("AnimationInteraction")
	if is_visible_in_tree() == false:
		set_process(false)
		set_physics_process(false)
	
func _physics_process(delta):
	var manger = Input.is_action_just_pressed("manger")
	var action = Input.is_action_just_pressed(xbox_button)
	
	cooldown.tick(delta)
	
	if action and cooldown.is_ready() :
		cooldown.action()
	if cooldown.is_actionning():
		player.eat = true
		player.get_node("Effet").color = player.colors_val[player.my_color]
		animation.play("action",-1,1/effect_time,false)
	else:
		player.eat = false

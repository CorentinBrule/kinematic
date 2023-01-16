extends Node2D
const Cooldown = preload('res://cooldown.gd')

var player
var cooldownPush
var cooldownSave
var animation
var effect_time
var cooldown_time

export(String, "LB", "A", "B", "X", "Y", "RB",  "RT", "LT") var xbox_button

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	effect_time = 0.5
	cooldown_time = 0.5
	cooldownPush = Cooldown.new(0.01, cooldown_time)
	cooldownSave = Cooldown.new(effect_time, cooldown_time)
	animation = player.get_node("AnimationInteraction")
	
func _process(delta):
	var push = Input.is_action_just_pressed("move")
	var action = Input.is_action_just_pressed(xbox_button)
	
	cooldownPush.tick(delta)
	cooldownSave.tick(delta)
	
	#print(push_cooldown.is_ready())
	
	if action and cooldownPush.is_ready() :
		cooldownPush.action()
		cooldownSave.action()
	else:
		player.pushing = false
	
	if cooldownSave.is_actionning():
		player.get_node("Effet").color = player.colors_val[player.my_color-1]
		animation.play("action",-1,1/effect_time,false)
		player.safe = true
	else:
		player.safe = false
		
	if cooldownPush.is_actionning():
		player.pushing = true
		#print(get_node("/root/Tableau/TileMap").get_cell(2,2))
	else:
		player.pushing = false
	

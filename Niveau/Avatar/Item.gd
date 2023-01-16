@tool
extends Node2D
class_name Item
@icon("res://assets/diamand_texture_21x21.png")

var avatar
signal input_changed

@export_enum("A", "B", "X", "Y", "LB", "RB", "LT", "RT") var xbox_button: set = change_input
var input_xbox_map = ["A", "B", "X", "Y", "LB", "RB", "LT", "RT"]
var input_keyboard = 0
var action_name
var initial_state = {}

func _ready():
	avatar = get_parent()
	#get_parent().get_parent().get_parent().get_parent().connect("custom_visibility_changed",Callable(self,"_on_Item_visiblity_changed"))
	connect("visibility_changed",Callable(get_parent(),"_on_item_visibility_changed"))
	connect("input_changed",Callable(get_parent(),"_on_item_input_changed"))
	connect("tree_entered",Callable(get_parent(),"_on_item_input_changed"))
	if not Engine.is_editor_hint():
		assert(avatar is CharacterBody2D) #,"L'objet '" + name + "' n'est pas l'enfant de l'avatar !")
	if is_visible_in_tree() == false:
		set_process(false)
		set_physics_process(false)
	
	action_name = get_name()
	#init_input(action_name, input_keyboard ,input_xbox_map.find(xbox_button))


func init_input(action_name, keyboard_key_scancode, button_index):
	if not InputMap.has_action(name):
		InputMap.add_action(name)
	var joypad_event = InputEventJoypadButton.new()
	joypad_event.device = 0
	joypad_event.button_index = button_index
	InputMap.action_add_event(name, joypad_event)
	
	if keyboard_key_scancode != 0:
		var keyboard_event = InputEventKey.new()
		keyboard_event.keycode = keyboard_key_scancode
		InputMap.action_add_event(name, keyboard_event)

func _process(delta):
	if not Engine.is_editor_hint():
		process(delta)

func process(delta):
	pass

func _physics_process(delta):
	if not Engine.is_editor_hint():
		physics_process(delta)

func physics_process(delta):
	pass

func change_input(new_value):
	xbox_button = new_value
	emit_signal("input_changed")

func reset():
	for state in initial_state.keys():
		set(state, initial_state[state])

#func _on_self_visibility_changed():
#	print("oui de la class")

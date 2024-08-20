tool
extends Node2D
class_name Item, "res://assets/diamand_texture_21x21.png"

const Cooldown = preload('res://Niveau/Avatar/cooldown.gd')

var avatar
signal input_changed

export(String, "A",  "B", "X", "Y", "LB", "RB", "LT", "RT") var xbox_button setget change_input
var input_xbox_map = ["A", "B", "X", "Y", "LB", "RB", "LT", "RT"]
var button_index
var keyboard_key_name
var keyboard_key_scancode
var action_name
var initial_state = {}
var joypad_event

var toggleable = false
var toggle = false

var has_cooldown
var has_effect

var cooldown
var effect

var cooldown_time = 0
var effect_time = 0

var cooldown_percent = 0
var progress_percent = 0

var action = false

func _ready():
	avatar = get_parent()
	#get_parent().get_parent().get_parent().get_parent().connect("custom_visibility_changed", self, "_on_Item_visiblity_changed")
	connect("visibility_changed", get_parent(), "_on_item_visibility_changed")
	connect("input_changed", get_parent(), "_on_item_input_changed")
	connect("tree_entered", get_parent(), "_on_item_input_changed")
	if not Engine.editor_hint:
		assert(avatar is KinematicBody2D, "L'objet '" + name + "' n'est pas l'enfant de l'avatar !")
	joypad_event = InputEventJoypadButton.new()

	#init_input(action_name, input_keyboard ,input_xbox_map.find(xbox_button))

func init():
	action_name = name
	button_index = input_xbox_map.find(xbox_button)
	input_xbox_map.find(xbox_button)
	
	if not Engine.editor_hint:
		if Global.has_touch_screen:
			if toggleable:
				toggle = true
			
	init_input()
	if is_visible() == false:
		set_process(false)
		set_physics_process(false)
	else:
		set_process(true)
		set_physics_process(true)
		
	if has_cooldown:
		cooldown = Timer.new()
		add_child(cooldown)
		cooldown.wait_time = cooldown_time
		cooldown.one_shot = true
		cooldown.connect("timeout", self, "_on_Cooldown_timeout")
	
	if has_effect:
		effect = Timer.new()
		add_child(effect)
		effect.wait_time = effect_time
		effect.one_shot = true
		effect.connect("timeout", self, "_on_Effect_timeout")

func init_input():
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	joypad_event.device = 0
	joypad_event.button_index = button_index
	InputMap.action_add_event(action_name, joypad_event)
	
	if keyboard_key_scancode != 0:
		var keyboard_event = InputEventKey.new()
		keyboard_event.scancode = keyboard_key_scancode
		InputMap.action_add_event(action_name, keyboard_event)

func _process(delta):
	if not Engine.editor_hint:
		process(delta)

func process(delta):
	pass

func _physics_process(delta):
	if not Engine.editor_hint:
		if toggle == false:
			action = Input.is_action_pressed(action_name)
		else:
			if Input.is_action_just_pressed(action_name) :
				action = !action
		
		physics_process(delta)

func physics_process(delta):
	pass

func change_input(new_value):
	# print(new_value)
	xbox_button = new_value
	emit_signal("input_changed")

func reset():
	for state in initial_state.keys():
		set(state, initial_state[state])

## Conditional properties exporter
func _get(property):
	match property:
		"toggle":            
			return toggle          

func _set(property, value):
	# Assume the property exists
	var retval: bool = true
	match property:
		"toggle":            
			toggle = value  
		"_effect_time":
			effect_time = value
		"_cooldown_time":
			cooldown_time = value
		_:
			# If here, trying to set a property we are not manually dealing with.
			retval = false
		#property_list_changed_notify()# update inspect
	return retval

func _get_property_list():
	var ret: Array = []
	if(toggleable):
		ret.append({
			"name": "toggle",
			"type": TYPE_BOOL,
		})
	
	return ret


#func _on_self_visibility_changed():
#	print("oui de la class")

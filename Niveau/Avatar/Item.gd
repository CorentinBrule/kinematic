@tool
@icon("res://assets/diamand_texture_21x21.png")
class_name Item
extends Node2D

const input_lib = preload("res://input_lib.gd")
const Cooldown = preload("res://Niveau/Avatar/cooldown.gd")

signal input_changed

@onready var avatar = get_parent()
@onready var action_name = get_name()
@export_enum("A", "B", "X", "Y", "LB", "RB", "LT", "RT") var xbox_button:String: set = change_input
var input_xbox_mapped
var keyboard_key_name
var keyboard_key_scancode
var initial_state = {}

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
	#get_parent().get_parent().get_parent().get_parent().connect("custom_visibility_changed",Callable(self,"_on_Item_visiblity_changed"))
	connect("visibility_changed",Callable(get_parent(),"_on_item_visibility_changed"))
	connect("input_changed",Callable(get_parent(),"_on_item_input_changed"))
	connect("tree_entered",Callable(get_parent(),"_on_item_input_changed"))
	if not Engine.is_editor_hint():
		assert(avatar is CharacterBody2D) #,"L'objet '" + name + "' n'est pas l'enfant de l'avatar !")
	input_xbox_mapped = input_lib.input_xbox_map[xbox_button]
	init()
	ready()

func ready():
	pass

func init():
	if not Engine.is_editor_hint():
		if Global.has_touch_screen:
			if toggleable:
				toggle = true
	init_input()
	if visible == false:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
	else:
		set_process(true)
		set_physics_process(true)
		set_process_input(true)
	
	if has_cooldown:
		cooldown = Timer.new()
		add_child(cooldown)
		cooldown.wait_time = cooldown_time
		cooldown.one_shot = true
		cooldown.connect("timeout",Callable(self,"_on_Cooldown_timeout"))
	
	if has_effect:
		effect = Timer.new()
		add_child(effect)
		effect.wait_time = effect_time
		effect.one_shot = true
		effect.connect("timeout",Callable(self,"_on_Effect_timeout"))

func init_input():
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if input_xbox_mapped.type == "JoyButton":
		var joypad_event = InputEventJoypadButton.new()
		joypad_event.device = 0
		joypad_event.button_index = input_xbox_mapped.val
		InputMap.action_add_event(action_name, joypad_event)
	elif input_xbox_mapped.type == "JoyAxis":
		var joypad_event = InputEventJoypadMotion.new()
		joypad_event.device = 0
		joypad_event.axis = input_xbox_mapped.val
		InputMap.action_add_event(action_name, joypad_event)
	
	if keyboard_key_scancode != 0:
		var keyboard_event = InputEventKey.new()
		keyboard_event.keycode = keyboard_key_scancode
		InputMap.action_add_event(action_name, keyboard_event)

func _process(delta):
	if not Engine.is_editor_hint():
		process(delta)

func process(delta):
	pass

func _physics_process(delta):
	if not Engine.is_editor_hint():
		if toggle == false:
			action = Input.is_action_pressed(action_name)
		else:
			if Input.is_action_just_pressed(action_name) :
				action = !action
		
		physics_process(delta)

func physics_process(delta):
	pass

func change_input(new_value):
	xbox_button = new_value
	emit_signal("input_changed")

func reset():
	for state in initial_state.keys():
		set(state, initial_state[state])

# conditional variable export
func _get_property_list():
	if Engine.is_editor_hint(): 
		var ret = []

		if toggleable:
			ret.append({
				"name": &"toggle",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT
			})
		return ret

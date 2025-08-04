@tool
extends HBoxContainer

const input_lib = preload("res://input_lib.gd")

var item = null
var no_item_action = false
@export var no_item_description:String = ""
var action
var action_name = ""

var has_progress = false
var has_cooldown = false

@onready var texture_progress = $%inaction_progress
@onready var texture_cooldown = $%cooldown_cache

var input_type = "keyboard"
#var input_display # is button_texture / key_texture / input_label
#var key_display
#var button_display
var key_name = ""
var key_color = Color(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init_no_item():
	var global_input_type = "keyboard"
	if not Engine.is_editor_hint():
		global_input_type = Global.input_type

	if no_item_description != "":
		$action_description.text = no_item_description
	else:
		$action_description.text = no_item_action
	
	var events = InputMap.action_get_events(no_item_action)	
	if global_input_type == "xbox":
		# is there a controller input?
		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				input_type = "xbox"
				key_name = event.as_text().split("(")[1].split(",")[0]
	else:
		for event in events: 
			if event is InputEventKey:
				input_type = "keyboard"
				if event.keycode != 0: 
					key_name = OS.get_keycode_string(event.keycode)
				elif event.physical_keycode != 0:
					key_name = OS.get_keycode_string(event.physical_keycode)
	init()

func init_item(_item):
	var global_input_type = "keyboard"
	if not Engine.is_editor_hint():
		global_input_type = Global.input_type

	item = _item
	action_name = item.get_name()
	$action_description.text = action_name
	
	if item.get("has_effect") and (item.get("infinite") == false or item.get("infinite") == null):
		has_progress = true
	if item.get("has_cooldown"):
		has_cooldown = true
	if item.visible == false: 
		hide()
	
	if global_input_type == "xbox" and item["xbox_button"] != "":
		input_type = "xbox"
		key_name = item.input_xbox_mapped.name
	else:
		input_type = "keyboard"
		key_name = item.keyboard_key_name
	
	init()

func init():
	if input_type == "keyboard":
		$%input_label/key_frame.show()
	else:
		$%input_label/key_frame.hide()

	key_color = Color(1,1,1)
	if key_name in input_lib.input_xbox_map or len(key_name) < 3: # "letter" buttons or key with short name
		if input_type == "xbox":
			key_color = input_lib.input_xbox_map[key_name].get("color", Color(1,1,1)) #txt & img btn color (get or white)
		$%input_label.text = key_name
		$%input_label.show()
		$%input_texture.hide()

	else:
		var loaded = load_input_texture(input_type, key_name)
		if loaded:
			$%input_texture.show()
			$%input_label.hide()
	$%input_label.set("theme_override_colors/font_color", key_color)
	$%inaction_progress.tint_progress = key_color

func load_input_texture(input_name:String, button_name:String):
	var texture_path = "res://assets/"+input_name+"_"+button_name+"_21x21.png"
	var loaded = false
	if ResourceLoader.exists(texture_path):
		$%input_texture.texture = load(texture_path)
		loaded = true
	else:
		push_error("file" + texture_path + "does not exist")
	return loaded

func update():
	if item != null:
		init_item(item)
	else:
		init_no_item()

func _process(delta):
	if not Engine.is_editor_hint():
		if item:
			action = item.action
		elif no_item_action:
			action = Input.is_action_pressed(no_item_action)
		# during transition
		#if $%input_label.visible_ratio < 1.0 :
			#if $%input_label/key_frame.visible:
				#%input_label/key_frame.value = 0
			#if $%%key_texture.visible:
		#else:
			#if $ActionDescription/ActionKey/cadreCarré.visible:
				#$ActionDescription/ActionKey/cadreCarré.value = 100
			#if $ActionDescription/ActionKey/cadreSpacebar.visible:
				#$ActionDescription/ActionKey/cadreCarré.value = 100
		if has_progress:
			texture_progress.value = item.progress_percent
		else:
			if action:
				texture_progress.value = 100
			else:
				texture_progress.value = 0
		if has_cooldown:
			texture_cooldown.value = item.cooldown_percent


func _get_property_list():
	InputMap.load_from_project_settings()
	var actions = InputMap.get_actions()
	var hint_string = ""
	for a in actions:
		hint_string += a + ","
	var properties = []
	properties.append({
		"name": "no_item_action",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string
	})
	return properties

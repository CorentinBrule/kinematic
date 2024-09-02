@tool
extends HBoxContainer

const input_lib = preload("res://input_lib.gd")

var has_progress = false
var has_cooldown = false
var texture_progress
var texture_cooldown
var action
var key_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_action):
	action = _action

	var action_name = action.get_name()
	texture_cooldown = $ActionDescription/ActionKey/cacheCooldown
	texture_progress = $ActionDescription/ActionKey/cadreDiamant
	var key_label = $ActionDescription/ActionKey
	
	# keyboard or controller	
	var regex = RegEx.new()
	regex.compile("(?i)(xbox|x-box|microsoft)")
	
	if regex.search(Input.get_joy_name(0)):
		key_name = action.input_xbox_mapped.name
		key_label.set("theme_override_colors/font_color", action.input_xbox_mapped.color)
		texture_progress.tint_progress = action.input_xbox_mapped.color
	else:
		key_name = action.keyboard_key_name
		#get_node("ActionDescription/ActionKey/cadreDiamant").hide()
		key_label.set("theme_override_colors/font_color", Color(1,1,1,1))
		texture_progress.tint_progress = Color(1,1,1,1)
		if key_name.length() == 1:
			get_node("ActionDescription/ActionKey/cadreCarré").show()
		if key_name == "space":
			get_node("ActionDescription/ActionKey/cadreSpacebar").show()
			key_name = ""
	var action_is_visible = action.visible
	
	var description_label = $ActionDescription
	
	description_label.text = action_name #
	
	print(key_name)
	key_label.text = key_name
	
	if action.get("has_effect") and (action.get("infinite") == false or action.get("infinite") == null):
		has_progress = true
		#texture_progress.tint_progress = action.input_xbox_mapped.color
	
	if action.get("has_cooldown"):
		has_cooldown = true
		
	if action_is_visible == false:
		hide()

func _process(delta):
	if not Engine.is_editor_hint():
		if has_progress:
			texture_progress.value = action.progress_percent
		else:
			if action.action:
				texture_progress.value = 100
			else:
				texture_progress.value = 0
		if has_cooldown:
			texture_cooldown.value = action.cooldown_percent

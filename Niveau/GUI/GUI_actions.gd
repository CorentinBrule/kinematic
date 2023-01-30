@tool
extends HBoxContainer

const input_lib = preload("res://input_lib.gd")

var has_progress = false
var texture_progress
var action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_action):
	action = _action

	var action_name = action.get_name()
	var key_name = action.input_xbox_mapped.name
	
	var action_is_visible = action.visible
	
	var description_label = $ActionDescription
	var key_label = $ActionDescription/ActionKey
	texture_progress = $ActionDescription/ActionKey/TextureProgressBar
	
	description_label.text = action_name #
	
	key_label.text = key_name
	
	key_label.set("theme_override_colors/font_color", action.input_xbox_mapped.color)
	
	if not action.get("progress_percent") == null:
		has_progress = true
		texture_progress.tint_progress = action.input_xbox_mapped.color
	else:
		texture_progress.hide()
		
	if action_is_visible == false:
		hide()

func _process(delta):
	if not Engine.is_editor_hint():
		if has_progress:
			texture_progress.value = action.progress_percent

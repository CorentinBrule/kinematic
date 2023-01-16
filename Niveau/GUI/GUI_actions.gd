@tool
extends HBoxContainer

var key_colors={
	"X":Color(0,0,1,1), #blue
	"A":Color(0,1,0,1), #green
	"B":Color(1,0,0,1), #red
	"Y":Color(1,1,0,1), #yellow
	"LT":Color(1,1,1,1), #white
	"RT":Color(1,1,1,1), #white
	"LB":Color(1,1,1,1), #white
	"RB":Color(1,1,1,1), #white
}

var has_progress = false
var texture_progress
var action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(_action):
	action = _action
	var action_name = action.get_name()
	var key_name = action.get("xbox_button")
	var action_is_visible = action.visible
	
	var description_label = $ActionDescription
	var key_label = $ActionDescription/ActionKey
	texture_progress = $ActionDescription/ActionKey/TextureProgressBar
	
	description_label.text = action_name #
	key_label.text = key_name
	
	key_label.set("custom_colors/font_color", key_colors.get(key_name))
	
	if not action.get("progress_percent") == null:
		has_progress = true
		texture_progress.tint_progress = key_colors[key_name]
	else:
		texture_progress.hide()
		
	if action_is_visible == false:
		hide()

func _process(delta):
	if not Engine.editor_hint:
		if has_progress:
			texture_progress.value = action.progress_percent

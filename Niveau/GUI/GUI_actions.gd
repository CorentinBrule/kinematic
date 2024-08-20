tool
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
		key_name = action.get("xbox_button")
		key_label.set("custom_colors/font_color", key_colors.get(key_name, Color(1,1,1,1)))
		texture_progress.tint_progress = key_colors.get(key_name, Color(1,1,1,1))
	else:
		key_name = action.keyboard_key_name
		key_label.set("custom_colors/font_color", Color(1,1,1,1))
		texture_progress.tint_progress = Color(1,1,1,1)
		if key_name.length() == 1:
			get_node("ActionDescription/ActionKey/cadreCarré").show()
		if key_name == "space":
			get_node("ActionDescription/ActionKey/cadreSpacebar").show()
			key_name = ""
	var action_is_visible = action.visible
	
	var description_label = $ActionDescription
	
	description_label.text = action_name #
	key_label.text = key_name
	
	if action.get("has_effect") and (action.get("infinite") == false or action.get("infinite") == null):
		has_progress = true
		#print(has_progress)
	
	if action.get("has_cooldown"):
		has_cooldown = true
	
	if action_is_visible == false:
		hide()

func _process(delta):
	if not Engine.editor_hint:
		if has_progress:
			#print(action.progress_percent)
			texture_progress.value = action.progress_percent
		else:
			if action.action:
				texture_progress.value = 100
			else:
				texture_progress.value = 0
		if has_cooldown:
			texture_cooldown.value = action.cooldown_percent

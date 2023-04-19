tool
extends HBoxContainer

var has_progress = false
var texture_progress
var action
var key_name = ""


func _ready():
	# interface "tête-bèche"
	if get_index() %2 == 0:
		pass
	else:
		$ActionDescription.align = Label.ALIGN_LEFT
		$ActionDescription/TouchButton.position.x = 70
		$ActionDescription/TouchButton.scale.x *= -1
		$ActionDescription/TouchButton/TextureProgress.fill_mode = TextureProgress.FILL_COUNTER_CLOCKWISE

func init(_action):
	action = _action
	
	var action_name = action.get_name()
	texture_progress = $ActionDescription/TouchButton/TextureProgress
	var action_is_visible = action.visible
	
	var description_label = $ActionDescription
	
	description_label.text = action_name
	
	$ActionDescription/TouchButton.action = action_name
	
	if action.get("progress_percent") != null and (action.get("infinite") == false or action.get("infinite") == null):
		has_progress = true
	
	if action_is_visible == false:
		hide()

func _process(delta):
	if not Engine.editor_hint:
		if action.get("toggleable"):
			if Input.is_action_just_pressed(action.action_name):
				if action.action:
					$ActionDescription/TouchButton/AnimationPlayer.play_backwards("toggle")
				else:
					$ActionDescription/TouchButton/AnimationPlayer.play("toggle")
					
		if action.action:
			texture_progress.tint_progress = Color(0.5,0.5,0.5,1)
			if has_progress:
				texture_progress.value = action.progress_percent
			else:
				texture_progress.value = 100
		else:
			if has_progress:
				texture_progress.value = action.progress_percent
				texture_progress.tint_progress = Color(0.5,0.5,0.5,0.2)
				texture_progress.tint_under = Color(0.2,0.2,0.2,1)
			else:
				texture_progress.value = 0
				texture_progress.tint_progress = Color(1,1,1,0)

func _on_Button_down():
	Input.action_press(action.get_name())
	
func _on_Button_up():
	Input.action_release(action.get_name())

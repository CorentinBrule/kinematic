@tool
extends HBoxContainer

var has_progress = false
var has_cooldown = false
var texture_progress
var texture_cooldown
var action
var item = null
var key_name = ""
var animation_name


func _ready():
	# interface "tête-bèche"
	if get_index() %2 == 0:
		animation_name = "toggle_droit"
		alignment = ALIGNMENT_BEGIN

		
	else:
		animation_name = "toggle_gauche"
		alignment = ALIGNMENT_END
		$ActionDescription.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		$ActionDescription/TouchButton.position.x = 100
		$ActionDescription/TouchButton.scale.x *= -1
		$ActionDescription/TouchButton/TextureProgress.fill_mode = TextureProgressBar.FILL_COUNTER_CLOCKWISE
		$ActionDescription/TouchButton/TextureCooldown.fill_mode = TextureProgressBar.FILL_COUNTER_CLOCKWISE

func init_item(_item):
	item = _item
	
	var action_name = item.get_name()
	texture_progress = $ActionDescription/TouchButton/TextureProgress
	texture_cooldown = $ActionDescription/TouchButton/TextureCooldown
	
	var description_label = $ActionDescription
	description_label.text = action_name
	$ActionDescription/TouchButton.action = action_name
	
	if item.get("has_effect"):
		has_progress = true
	if item.get("has_cooldown"):
		# ne fonctionne pas ici
		has_cooldown = true
	if item.visible == false:
		hide()

func _process(delta):
	if not Engine.is_editor_hint():
		action = item.action
		if item.get("toggle"):
			if Input.is_action_just_pressed(item.get_name()):
				if action:
					$ActionDescription/TouchButton/AnimationPlayer.play_backwards("toggle_gauche")
				else:
					$ActionDescription/TouchButton/AnimationPlayer.play("toggle_gauche")
		if action:
			texture_progress.tint_progress = Color(0.5,0.5,0.5,1)
			if has_progress:
				texture_progress.value = item.progress_percent
			else:
				texture_progress.value = 100
		else:
			if has_progress:
				texture_progress.value = item.progress_percent
				texture_progress.tint_progress = Color(0.5,0.5,0.5,0.2)
				texture_progress.tint_under = Color(0.2,0.2,0.2,1)
			else:
				texture_progress.value = 0
				texture_progress.tint_progress = Color(1,1,1,0)
		if item.get("has_cooldown"):
			texture_cooldown.value = 100 - item.cooldown_percent
		else:
			texture_cooldown.value = 100

func _on_Button_down():
	Input.action_press(item.get_name())
	
func _on_Button_up():
	Input.action_release(item.get_name())

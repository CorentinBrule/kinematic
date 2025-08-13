@tool
extends Node2D

var avatar
var color
const action_scene = preload("res://Niveau/GUI/GUI_actions.tscn")
const action_scene_touch = preload("res://Niveau/GUI/GUI_actions_touch.tscn")
const GUIActionsClass = preload("res://Niveau/GUI/GUI_actions.gd")

var base_size = Vector2(384,384)

var width_out_game_interface = base_size.x

var all_labels = []
var all_transitions_check = []
var is_text_transition = false
var is_reverse_transition = false
var transition_duration = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		$outGameGUI/cache_GUI_actions_input.hide()
	get_tree().get_root().connect("size_changed",Callable(self,"on_resize_window"))
	adapt_interface()
	update_interface(Global.has_touch_screen)

func _process(delta):
	if not Engine.is_editor_hint():
		if get_parent().get_node("Camera2D").zoom.x >= get_parent().get_node("Camera2D").mid_zoom.x:
			$outGameGUI/HBoxContainer_gauche.hide()
			$outGameGUI/meta.hide()
		else: 
			$outGameGUI/HBoxContainer_gauche.show()
			$outGameGUI/meta.show()
			
	if is_text_transition and not Engine.is_editor_hint():
		text_transition(is_reverse_transition, delta/transition_duration)
		
func prepare_text_transition(reverse:bool = false):
	is_text_transition = true
	is_reverse_transition = reverse
	all_labels = []
	all_transitions_check = []
	for child in find_children("*","",true,false):
		if (child is Label or child is RichTextLabel) and not child.get_meta("avoid_transition",false):
			all_labels.append(child)
			all_transitions_check.append(false)
			if not reverse:
				child.visible_ratio = 0.0

func text_transition(reverse:bool = false, speed:float = 0.01):
	for i in all_labels.size():
		if all_transitions_check[i] == false:
			if is_instance_valid(all_labels[i]):
				if reverse:
					if all_labels[i].visible_ratio > 0.0:
						#all_labels[i].visible_ratio -= 1.0/ all_labels[i].text.length()/2
						all_labels[i].visible_ratio -= speed
					else:
						all_transitions_check[i] = true
				else:
					if all_labels[i].visible_ratio < 1.0:
						#all_labels[i].visible_ratio += 1.0/ all_labels[i].text.length()/2
						all_labels[i].visible_ratio += speed
					else:
						all_transitions_check[i] = true
			else:
				all_transitions_check[i] = true
		if not false in all_transitions_check:
			is_text_transition = false
			print("transition finish")

func init():
	avatar = get_parent().get_node("Avatar")
	$"%char_name".text = get_parent().char_name
	$"%char_name".set("theme_override_colors/font_color", avatar.colors_val[avatar.my_color])
	$"%narrative".text = get_parent().narrative
	
	## init action containers
	var actions_touch_container = $"%ActionsContainerTouch"
	var actions_touch_container_overflow = $"%ActionsContainerTouch2"

	#clean actions containers
	for action in $"%ActionsContainer".get_children():
		action.free()
	for action in actions_touch_container.get_children():
		action.free()
	for action in actions_touch_container_overflow.get_children():
		action.free()
	
	var max_height_touch = actions_touch_container.size.y
	var index_action = 0
	for item in avatar.get_active_items():
		#print(item)
		var gui_action = action_scene.instantiate()
		#print(gui_action)
		gui_action.init_item(item)
		$"%ActionsContainer".add_child(gui_action)
		## hide before transition
		if not Engine.is_editor_hint():
			gui_action.get_node("action_description").visible_ratio = 0.0
		
		var gui_action_touch = action_scene_touch.instantiate()
		gui_action_touch.init_item(item)

		if index_action < 5:
			actions_touch_container.add_child(gui_action_touch)
			actions_touch_container.move_child(gui_action_touch, 0)
		else:
			actions_touch_container_overflow.add_child(gui_action_touch)
		index_action += 1

	for child in find_children("*","", true,true):
		if child is GUIActionsClass:
			if child.no_item_action != null:
				child.init_no_item()
				if not Engine.is_editor_hint():
					child.get_node("action_description").visible_ratio = 0.0

	if get_parent().get_parent().has_node("Menu"):
		$"%Gui_actions_menu".visible = true
		
	$"%meta_label".visible = true
	var date =  get_parent().date
	$"%meta_label".text = "%s/%s/%s " % ["%02d"%date.day, "%02d"%date.month, "%04d"%date.year]
	if (date.hour != 0):
		$"%meta_label".text += str(date.hour) + "h "
	$"%meta_label".text += get_parent().groupe_name
	
	await get_tree().process_frame
	
	if Engine.is_editor_hint():
		var tool_node = get_parent().get_parent()
		update_interface(tool_node.has_touch_screen)
	else:
		update_interface(Global.has_touch_screen)
		prepare_text_transition(false)

	adapt_interface()

func _input(event):
	if event is InputEventKey:
		if Global.has_touch_screen:
			update_interface(false)
		Global.has_touch_screen = false
		if Global.input_type != "keyboard":
			Global.input_type = "keyboard"
			update_GUI_actions()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if Global.has_touch_screen:
			update_interface(false)
		var regex = RegEx.new()
		regex.compile("(?i)(xbox|x-box|microsoft)")
		if regex.search(Input.get_joy_name(0)):
			if Global.input_type != "xbox":
				Global.input_type = "xbox"
				update_GUI_actions()
		else:
			Global.input_type = "?"
		Global.has_touch_screen = false
	elif event is InputEventScreenTouch:
		if not Global.has_touch_screen:
			update_interface(true)
		Global.input_type = "touch"
		Global.has_touch_screen = true
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		pass
	elif event is InputEventAction:
		pass
	else:
		print("Unknown input type")
		print(event)

func update_GUI_actions():
	for child in find_children("*","", true,false):
		if child is GUIActionsClass:
			child.update()

func update_interface(has_touch_screen):
	#print("update interface")
	#print(has_touch_screen)
	if has_touch_screen:
		$"%ActionsContainer".hide()
		$"%ActionsContainerTouch".show()
		$"%ActionsContainerTouch2".show()
		$touch_controls.show()
		$"%Gui_actions_zoom".hide()
		$"%Gui_actions_reset".hide()
		$"%Gui_actions_menu".hide()
		$"%bas_droit/MarginContainer".show()
	else:
		$"%ActionsContainerTouch".hide()
		$"%ActionsContainerTouch2".hide()
		$touch_controls.hide()
		$"%ActionsContainer".show()
		$"%Gui_actions_zoom".show()
		$"%Gui_actions_reset".show()
		$"%Gui_actions_menu".show()
		$"%bas_droit/MarginContainer".hide()
		
func adapt_interface():
	if not Engine.is_editor_hint():
		var resize_ratio = float(get_viewport().size.x )/ float(get_viewport().size.y)
		width_out_game_interface = max(base_size.x * ((resize_ratio - 0.6)),180)
		$outGameGUI/HBoxContainer_droit.size.x = width_out_game_interface
		$outGameGUI/HBoxContainer_gauche.size.x = width_out_game_interface
		$outGameGUI/HBoxContainer_gauche.position.x = ($outGameGUI/HBoxContainer_gauche.size.x*-1)
		$outGameGUI/meta.position.x = ($outGameGUI/HBoxContainer_gauche.size.x*-1)
		$"%bas_droit".size.x = $outGameGUI/HBoxContainer_droit.size.x

func on_resize_window():
	if not Engine.is_editor_hint():
		adapt_interface()
		get_parent().get_node("Camera2D").update_mid_zoom(width_out_game_interface)
		get_parent().get_node("Camera2D").adapt_clips()
		get_parent().get_node("Camera2D").force_update_clip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

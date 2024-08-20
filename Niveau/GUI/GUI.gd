tool
extends Node2D
var tool_node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var out_game_interface_droit
var out_game_interface_gauche
var out_game_meta
var out_game_bas_droit
var actions_container
var actions_touch_container
var actions_touch_container_overflow

var avatar
var color
const action_scene = preload("res://Niveau/GUI/GUI_actions.tscn")
const action_scene_touch = preload("res://Niveau/GUI/GUI_actions_touch.tscn")
var base_size = Vector2(384,384)

var width_out_game_interface = base_size.x

# Called when the node enters the scene tree for the first time.
func _ready():
	tool_node = get_tree().root.get_child(0)
	get_tree().get_root().connect("size_changed", self, "on_resize_window")
	out_game_interface_droit = $outGameGUI/HBoxContainer_droit
	out_game_interface_gauche = $outGameGUI/HBoxContainer_gauche
	out_game_meta = $outGameGUI/meta
	out_game_bas_droit = $"%bas_droit"
	actions_container = $"%ActionsContainer"
	actions_touch_container = $"%ActionsContainerTouch"
	actions_touch_container_overflow = $"%ActionsContainerTouch2"
	adapt_interface()

func init():
	avatar = get_parent().get_node("Avatar")
	$"%char_name".text = get_parent().char_name
	$"%char_name".set("custom_colors/font_color", avatar.colors_val[avatar.my_color])
	$"%narrative".text = get_parent().narrative
	
	#clean actions_container
	for action in actions_container.get_children():
		action.free()
	for action in actions_touch_container.get_children():
		action.free()
	for action in actions_touch_container_overflow.get_children():
		action.free()
	
	var max_height_touch = actions_touch_container.rect_size.y
	var index_action = 0
	for item in avatar.get_active_items():
		#print(item)
		var gui_action = action_scene.instance()
		#print(gui_action)
		gui_action.init(item)
		actions_container.add_child(gui_action)
		
		var gui_action_touch = action_scene_touch.instance()
		gui_action_touch.init(item)

		if index_action < 5:
			actions_touch_container.add_child(gui_action_touch)
			actions_touch_container.move_child(gui_action_touch, 0)
		else:
			actions_touch_container_overflow.add_child(gui_action_touch)
		index_action += 1
	
	update_interface()

	if get_parent().get_parent().has_node("Menu"):
		$"%retourMenu".visible = true
		
	$"%meta_label".visible = true
	var date =  get_parent().date
	$"%meta_label".text = "%s/%s/%s " % [date.day, date.month, date.year] 
	if (date.hour != 0):
		$"%meta_label".text += str(date.hour) + "h "
	$"%meta_label".text += get_parent().groupe_name
	
	var regex = RegEx.new()
	regex.compile("(?i)(xbox|x-box|microsoft)")
	if regex.search(Input.get_joy_name(0)):
		$"%TextureStart".show()
		$"%TextureEsc".hide()
		$"%GuiActionZoom".find_node("ActionButton").hide()
		$"%GuiActionZoom".find_node("ActionKey").show()
	else:
		$"%TextureEsc".show()
		$"%TextureStart".hide()
		$"%GuiActionZoom".find_node("ActionButton").show()
		$"%GuiActionZoom".find_node("ActionKey").hide()
	yield(get_tree(), "idle_frame")
	
	adapt_interface()

func _input(event):
	if (event is InputEventKey and event.pressed) or (event is InputEventJoypadButton):
		tool_node.has_touch_screen = false
		update_interface()
	elif event is InputEventScreenTouch:
		tool_node.has_touch_screen = true
		update_interface()

func update_interface():
	#print(Global.has_touch_screen)
	if tool_node.has_touch_screen:
		actions_container.hide()
		actions_touch_container.show()
		actions_touch_container_overflow.show()
		$touch_controls.show()
		$"%GuiActionZoom".hide()
		$"%bas_droit/MarginContainer".show()
		$"%TextureStart".show()
		$"%TextureEsc".hide()
	else:
		actions_touch_container.hide()
		actions_touch_container_overflow.hide()
		$touch_controls.hide()
		actions_container.show()
		$"%GuiActionZoom".show()
		$"%bas_droit/MarginContainer".hide()
		
func adapt_interface():
	if not Engine.editor_hint:
		var resize_ratio = get_viewport().size.x / get_viewport().size.y
		width_out_game_interface = max(base_size.x * ((resize_ratio - 0.8)),180)
		out_game_interface_droit.rect_size.x = width_out_game_interface
		out_game_interface_gauche.rect_size.x = width_out_game_interface
		out_game_interface_gauche.rect_position.x = (out_game_interface_gauche.rect_size.x*-1)
		out_game_meta.rect_position.x = (out_game_interface_gauche.rect_size.x*-1)
		out_game_bas_droit.rect_size.x = out_game_interface_droit.rect_size.x + 50

func on_resize_window():
	if not Engine.editor_hint:
		adapt_interface()
		get_parent().get_node("Camera2D").update_mid_zoom(width_out_game_interface)
		get_parent().get_node("Camera2D").adapt_clips()
		get_parent().get_node("Camera2D").force_update_clip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

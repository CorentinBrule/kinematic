tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var out_game_interface_droit
var out_game_interface_gauche
var out_game_meta
var out_game_esc
var actions_container

var avatar
var color
const action_scene = preload("res://Niveau/GUI/GUI_actions.tscn")
var base_size = Vector2(384,384)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "on_resize_window")
	out_game_interface_droit = $outGameGUI/HBoxContainer_droit
	out_game_interface_gauche = $outGameGUI/HBoxContainer_gauche
	out_game_meta = $outGameGUI/meta
	out_game_esc = $outGameGUI/retourMenu
	actions_container = $"%ActionsContainer"
	adapt_interface()

func init():
	avatar = get_parent().get_node("Avatar")
	$"%char_name".text = get_parent().char_name
	$"%char_name".set("custom_colors/font_color", avatar.colors_val[avatar.my_color])
	$"%narrative".text = get_parent().narrative
	
	#clean actions_container
	for action in actions_container.get_children():
		action.free()
	
	for item in avatar.get_active_items():
		#print(item)
		var gui_action = action_scene.instance()
		#print(gui_action)
		gui_action.init(item)
		actions_container.add_child(gui_action)
	
	if get_parent().get_parent().has_node("Menu"):
		$"%meta_label".visible = true
		var date =  get_parent().date
		$"%meta_label".text = "%s/%s/%s " % [date.day, date.month, date.year] 
		if (date.hour != 0):
			$"%meta_label".text += str(date.hour) + "h "
		$"%meta_label".text += get_parent().groupe_name
		$"%retourMenu".visible = true
		print(Input.get_joy_name(0))
		var regex = RegEx.new()
		regex.compile("(?i)(xbox|x-box|microsoft)")
		if regex.search(Input.get_joy_name(0)):
			$"%TextureStart".show()
	
	yield(get_tree(), "idle_frame")
	adapt_interface()

func adapt_interface():
	if not Engine.editor_hint:
		var resize_ratio = get_viewport().size.x / get_viewport().size.y
		var out_game_interface_width = base_size.x * ((resize_ratio - 0.8))
		out_game_interface_droit.rect_size.x = max(out_game_interface_width, 150)
		out_game_interface_gauche.rect_size.x = max(out_game_interface_width, 150) 
		out_game_interface_gauche.rect_position.x = (out_game_interface_gauche.rect_size.x*-1)
		out_game_meta.rect_position.x = (out_game_interface_gauche.rect_size.x*-1)
		out_game_esc.rect_position.x = out_game_interface_droit.rect_size.x + 50

func on_resize_window():
	if not Engine.editor_hint:
		adapt_interface()
		get_parent().get_node("Camera2D").adapt_clips()
		get_parent().get_node("Camera2D").force_update_clip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

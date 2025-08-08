@tool
extends Node

# pas vraiment script de "Jeu" 
# mais plutot script de centralisation des évenements de l'éditeur
# et déclanchement des events de modification dans l'éditeur

@export var auto_cam:bool = false
@export var joystick_zoom:bool = false
@export var mobile_emulation:bool = false : set = change_mobile_emulation
@export var click_to_move = false
@export var menu_for_export = false : set = change_menu_for_export
@export var save_folder_path:String = "res://save/"

var avatar
var GUI
var camera
var has_touch_screen
var tool_is_ready = false # required variable to avoid bugs in the editor tool when the scene reloads

func _ready():
	if Engine.is_editor_hint():
		tool_is_ready = true
	avatar = get_node("Niveau/Avatar")
	avatar.get_node("Color").color = avatar.colors_val[avatar.my_color]
	GUI = get_node("Niveau/GUI")
	GUI.init()
	camera = get_node("Niveau/Camera2D")
	camera.auto_cam = auto_cam
	camera.joystick_zoom = joystick_zoom

	if(Global.has_touch_screen):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.has_touch_screen = mobile_emulation
		has_touch_screen = mobile_emulation
	
func _process(delta):
	if Engine.is_editor_hint():
		pass

func _on_Avatar_color_change():
	if Engine.is_editor_hint():
		avatar = get_node("Niveau/Avatar")
		avatar.get_node("Color").color = avatar.colors_val[avatar.my_color]
		GUI = get_node("Niveau/GUI")
		GUI.init()

func _on_Avatar_item_change():
	if Engine.is_editor_hint():
		GUI = get_node("Niveau/GUI")
		GUI.init()

func _on_Niveau_var_changed():
	if Engine.is_editor_hint():
		print("event checked change")
		GUI = get_node("Niveau/GUI")
		GUI.init()

func change_mobile_emulation(val):
	mobile_emulation = val
	print(val)
	if Engine.is_editor_hint():
		ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse",val)
		ProjectSettings.save()
		GUI.update_interface(val)

func change_menu_for_export(val):
	menu_for_export = val
	var menu = get_node_or_null("Menu")
	print(menu)
	if Engine.is_editor_hint() and tool_is_ready:
		if menu_for_export == true:
			if menu == null:
				var scene = load("res://Menu.tscn")
				var instance = scene.instantiate()
				add_child(instance)
				instance.set_owner(self)
				instance.hide()
		else:
			if menu != null:
				menu.free()

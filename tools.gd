tool
extends Node

# pas vraiment script de "Jeu" 
# mais plutot script de centralisation des évenements de l'éditeur
# et déclanchement des events de modification dans l'éditeur

export(bool) var auto_cam = false
export(bool) var joystick_zoom = false
export(bool) var mobile_emulation = false setget _change_mobile_emulation
export(bool) var click_to_move = false

export(String) var save_folder_path = "res://save/"

var avatar
var GUI
var camera

func _ready():
	avatar = get_node("Niveau/Avatar")
	avatar.get_node("Color").color = avatar.colors_val[avatar.my_color]
	GUI = get_node("Niveau/GUI")
	GUI.init()
	camera = get_node("Niveau/Camera2D")
	camera.auto_cam = auto_cam
	camera.joystick_zoom = joystick_zoom
	
func _process(delta):
	if Engine.editor_hint:
		pass

func _on_Avatar_color_change():
	if Engine.editor_hint:
		avatar = get_node("Niveau/Avatar")
		avatar.get_node("Color").color = avatar.colors_val[avatar.my_color]
		GUI = get_node("Niveau/GUI")
		GUI.init()

func _on_Avatar_item_change():
	if Engine.editor_hint:
		GUI = get_node("Niveau/GUI")
		GUI.init()

func _on_Niveau_var_changed():
	if Engine.editor_hint:
		print("event on change")
		GUI = get_node("Niveau/GUI")
		GUI.init()

func _change_mobile_emulation(val):
	mobile_emulation = val
	if Engine.editor_hint:
		ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse",val)
		ProjectSettings.save()

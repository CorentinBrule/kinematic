tool
extends Node

# pas vraiment script de "Jeu" 
# mais plutot script de centralisation des évenements de l'éditeur
# et déclanchement des events de modification dans l'éditeur

export(bool) var auto_cam = false
export(bool) var joystick_zoom = false
export(bool) var menu_and_export_mode = false setget _set_menu

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

func _set_menu(val):
	menu_and_export_mode = val
	if val:
		add_child(load("res://Menu.tscn").instance())
		$Menu.hide()
	else:
		if has_node("Menu"):
			$Menu.queue_free()

@tool
extends Node

# pas vraiment script de "Jeu" 
# mais plutot script de centralisation des évenements de l'éditeur
# et déclanchement des events de modification dans l'éditeur

@export var auto_cam:bool = false
@export var joystick_zoom:bool = false
@export var mobile_emulation:bool = false :	set = change_mobile_emulation
@export var click_to_move = false
@export var save_folder_path:String = "res://save/"

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
	var action_caintainer_keyboard = get_node("Niveau/GUI/outGameGUI/HBoxContainer_droit/VBoxContainer/ActionsContainer")
	var action_container_touch_droit = get_node("Niveau/GUI/outGameGUI/HBoxContainer_droit/VBoxContainer/ActionsContainerTouch")
	var action_container_touch_overflow = get_node("Niveau/GUI/outGameGUI/ActionsContainerTouchOverflow/ActionsContainerTouch2")
	var main_touch_controls = get_node("Niveau/GUI/touch_controls")
	if Engine.is_editor_hint():
		ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse",val)
		ProjectSettings.save()
		if val:
			action_container_touch_droit.show()
			action_container_touch_overflow.show()
			main_touch_controls.show()
			action_caintainer_keyboard.hide()
		else:
			action_container_touch_overflow.hide()
			action_container_touch_droit.hide()
			main_touch_controls.hide()
			action_caintainer_keyboard.show()

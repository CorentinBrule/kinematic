@tool
extends Node

# pas vraiment script de "Jeu" 
# mais plutot script de centralisation des évenements de l'éditeur
# et déclanchement des events de modification dans l'éditeur

@export var auto_cam:bool = false
@export var joystick_zoom:bool = false
@export var save_folder_path:String = "res://save/"
@export var save_server_url:String = "http://localhost/kinematique/saves.php"

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


tool
extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var editor

# Called when the node enters the scene tree for the first time.
func _ready():
	editor = get_node("/root/EditorNode")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonSave_pressed():
	print("exec saveFile.gd")
	var script := load("res://addons/main_screen/saveFile.gd")
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		script.new().main(get_tree().get_edited_scene_root())
	else:
		print("'Jeu' n'est pas la scene sélectionné")


func _on_ButtonLoad_pressed():
	print("exec loadFile.gd")
	var script := load("res://addons/main_screen/loadFile.gd")
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		script.new().main(get_tree().get_edited_scene_root())
	else:
		print("'Jeu' n'est pas la scene sélectionné")

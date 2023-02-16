tool
extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var editor
var current_scene
# Called when the node enters the scene tree for the first time.
func _ready():
	editor = get_node("/root/EditorNode")
	current_scene = get_tree().get_root()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonSave_pressed():
	print("exec saveFile.gd")
	var script := load("res://addons/main_screen/saveFile.gd")
	
	var save_folder_path
	if $"%ExternalSave/CheckBox".pressed:
		save_folder_path = $"%ExternalSave/InputPath".text
	else:
		save_folder_path = null
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		script.new().main(get_tree().get_edited_scene_root(), save_folder_path)
	else:
		print("'Jeu' n'est pas la scene sélectionné")


func _on_ButtonLoad_pressed():
	print("exec loadFile.gd")
	var script := load("res://addons/main_screen/loadFile.gd")
	
	var save_folder_path
	if $"%ExternalSave/CheckBox".pressed:
		save_folder_path = $"%ExternalSave/InputPath".text
	else:
		save_folder_path = null
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		script.new().main(get_tree().get_edited_scene_root(), save_folder_path)
	else:
		print("'Jeu' n'est pas la scene sélectionné")


func _on_ExternalSave_InputPath_text_changed(new_text):
	$"%ExternalSave/CheckBox".pressed = true


func _on_ExternalSave_LoadPath_pressed():
	var fileDialog = EditorFileDialog.new()
	fileDialog.mode = EditorFileDialog.MODE_OPEN_DIR
	fileDialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	fileDialog.display_mode = 1
	fileDialog.resizable = true
	
	fileDialog.current_dir = "save/"
	
	fileDialog.connect("dir_selected", self, "_on_fileDialog_dir_selected")
	#fileDialog.get_cancel().connect("pressed", self, "_on_fileDialog_cancel")
	#fileDialog.connect("modal_closed", self, "_on_fileDialog_modal_closed")

	add_child(fileDialog)
	fileDialog.set_meta("_created_by", self)

	fileDialog.popup_centered_ratio()

func _on_fileDialog_dir_selected(dir_path : String):
	$"CenterContainer/MenuSave/ExternalSave/InputPath".text = dir_path
	$"CenterContainer/MenuSave/ExternalSave/CheckBox".pressed = true

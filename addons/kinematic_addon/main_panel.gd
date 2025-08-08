@tool
extends Control

var current_scene
const default_save_folder_path = "res://save/"
var save_folder_path = default_save_folder_path


func _ready():
	$%ExternalSave_InputPath.placeholder_text = default_save_folder_path
	$%ExternalSave_InputPath.text = default_save_folder_path
	current_scene = get_tree().get_root()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonSave_pressed():
	print("exec saveFile.gd")
	var script := load("res://addons/kinematic_addon/saveFile.gd")
	
	if $"%ExternalSave_CheckBox".button_pressed:
		save_folder_path = $"%ExternalSave_InputPath".text
	else:
		save_folder_path = default_save_folder_path
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		$%Error.text = ""
		$%Error/Error_arrow.hide()
		var dir = DirAccess.open(save_folder_path)
		if dir != null:
			script.new().main(get_tree().get_edited_scene_root(), save_folder_path)
			$%Error.text = ""
		else:
			$%Error.text = "Le dossier n'existe pas"
	else:
		$%Error.text = "Il faut que la scène 'Jeu' soit l'onglet actif"
		$%Error/Error_arrow.show()


func _on_ButtonLoad_pressed():
	print("exec loadFile.gd")
	var script := load("res://addons/kinematic_addon/loadFile.gd")
	
	if get_tree().get_edited_scene_root().name == "Jeu":
		#editor.set_edited_scene("Jeu")
		$%Error.text = ""
		$%Error/Error_arrow.hide()
		var dir = DirAccess.open(save_folder_path)
		if dir != null:
			script.new().main(get_tree().get_edited_scene_root(), save_folder_path)
			$%Error.text = ""
		else:
			$%Error.text = "Le dossier n'existe pas"
	else:
		$%Error.text = "Il faut que la scène 'Jeu' soit l'onglet actif"
		$%Error/Error_arrow.show()


func _on_ExternalSave_InputPath_text_changed(new_text):
	print("CHANGE")
	if new_text != "res://save":
		$"%ExternalSave_CheckBox".button_pressed = true
	else:
		$"%ExternalSave_CheckBox".button_pressed = false
	save_folder_path = new_text

func _on_ExternalSave_LoadPath_pressed():
	var fileDialog = EditorFileDialog.new()
	fileDialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	fileDialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	fileDialog.display_mode = 1
	
	fileDialog.current_dir = save_folder_path
	
	fileDialog.connect("dir_selected", Callable(self, "_on_fileDialog_dir_selected"))
	#fileDialog.get_cancel().connect("pressed", self, "_on_fileDialog_cancel")
	#fileDialog.connect("modal_closed", self, "_on_fileDialog_modal_closed")

	add_child(fileDialog)
	fileDialog.set_meta("_created_by", self)

	fileDialog.popup_centered_ratio()

func _on_fileDialog_dir_selected(dir_path : String):
	var dir = DirAccess.open(dir_path)
	if dir != null:
		save_folder_path = dir_path
		$"%ExternalSave_InputPath".text = dir_path
		$"%ExternalSave_CheckBox".button_pressed = true
		$%Error.text = ""
	else:
		$%Error.text = "Le dossier n'existe pas"

func _on_ExternalSave_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		save_folder_path = $"%ExternalSave_InputPath".text
		$%ExternalSave_InputPath.editable = true
	else:
		save_folder_path = default_save_folder_path
		$%ExternalSave_InputPath.editable = false

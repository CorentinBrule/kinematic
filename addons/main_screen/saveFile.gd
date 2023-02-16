@tool
extends EditorScript

var fileDialog : EditorFileDialog = null
var edited_scene

const TileMap_path = "Niveau/TileMap"
const Avatar_path = "Niveau/Avatar"

# save library
const save_lib = preload("res://save_lib.gd")

func _run():
	# run script form script editor context
	# you must have selected the right scene !
	main(get_scene())
	
func main(_edited_scene, default_path="save/"):
	edited_scene = _edited_scene
	
	#get date info:
	var date = edited_scene.get_node("Niveau").date
	if date["day"] == 0 or date["month"] == 0:
		date = Time.get_datetime_dict_from_system()
	
	fileDialog = EditorFileDialog.new()
	fileDialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	fileDialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	fileDialog.display_mode = 1
	
	if default_path == null:
		default_path = "save/"
	default_path = default_path.replace("res://","") # fix godot 4 current_dir n'a plus l'air de comprendre "res://"
	
	fileDialog.current_dir = default_path
	
	fileDialog.current_file = "save-%04d-%02d-%02d-%02dh" % [date.year, date.month, date.day, date.hour]
	if edited_scene.get_node("Niveau").groupe_name != "":
		fileDialog.current_file += "-" + edited_scene.get_node("Niveau").groupe_name.replace(" ","_").replace("'","_")
	fileDialog.current_file += ".json"
	
	fileDialog.connect("file_selected",Callable(self,"_on_fileDialog_file_selected"))
	fileDialog.get_cancel_button().connect("pressed",Callable(self,"_on_fileDialog_cancel"))
	fileDialog.connect("close_requested",Callable(self,"_on_fileDialog_close_requested"))
	
	var viewport = get_editor_interface().get_editor_main_screen()
	viewport.add_child(fileDialog)
	fileDialog.set_meta("_created_by", self)
	
	fileDialog.popup_centered_ratio()


func _on_fileDialog_file_selected(path : String):
	print(path)
	if (fileDialog != null):
		fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.
	save_lib.save_file(edited_scene, path)
	
func _on_fileDialog_cancel():
	fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.

func _on_fileDialog_close_requested():
	fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.



func get_edited_root() -> Node:
	var plugin = EditorPlugin.new()
	var eds = plugin.get_selection()
	var selected = eds.get_selected_nodes()
	if selected.size():
		return selected[0].get_tree().get_edited_scene_root()
	return null

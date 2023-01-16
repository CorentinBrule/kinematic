tool
extends EditorScript

var fileDialog : EditorFileDialog = null
var edited_scene

const TileMap_path = "Niveau/TileMap"
const Avatar_path = "Niveau/Avatar"

# save library
const save_lib = preload("res://save_lib.gd")

func _run():
	# run script form script editor context
	main(get_scene())

func main(_edited_scene):
	
	edited_scene = _edited_scene
	
	fileDialog = EditorFileDialog.new()
	fileDialog.mode = EditorFileDialog.MODE_OPEN_FILE
	fileDialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	fileDialog.display_mode = 1
	fileDialog.current_file = "save.json"
	fileDialog.resizable = true
	
	fileDialog.current_dir = "save/"
	
	fileDialog.connect("file_selected", self, "_on_fileDialog_file_selected")
	fileDialog.get_cancel().connect("pressed", self, "_on_fileDialog_cancel")
	fileDialog.connect("modal_closed", self, "_on_fileDialog_modal_closed")

	var viewport = get_editor_interface().get_editor_viewport()
	viewport.add_child(fileDialog)
	fileDialog.set_meta("_created_by", self)

	fileDialog.popup_centered_ratio()


func _on_fileDialog_file_selected(file_path : String):
	print(file_path)
	if (fileDialog != null):
		fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.
	var tilemap = edited_scene.get_node(TileMap_path)
	#tilemap.clear()
	save_lib.load_file(edited_scene, file_path)

func _on_fileDialog_cancel():
	fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.

func _on_fileDialog_modal_closed():
	fileDialog.queue_free() # Dialog has to be freed in order for the script to be called again.

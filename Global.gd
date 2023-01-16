extends Node

var current_scene = null
var bool_start = true
var bool_save = true

var level_from_save = false

const Niveau_path = "Niveau"
const TileMap_path = "Niveau/TileMap"
const Avatar_path = "Niveau/Avatar"
const GUI_path = "Niveau/GUI"
const Camera_path = "Niveau/Camera2D"

# save library
const save_lib = preload("res://save_lib.gd")

var base_size
var base_center

var colors = ["Rouge","Vert","Bleu"]
var color_picker = {
	"Rouge": Color(1,0,0,1),
	"Vert": Color(0,1,0,1),
	"Bleu":	Color(0,0,1,1)
}

var avatar

var save_folder_path = "res://save/"
var save_files_path = []
var save_files_data = []
var save_index = 0

var is_menu = false

func _ready():
	var root = get_tree().get_root()
	base_size = get_viewport().size
	base_center = Vector2(base_size.x/2, base_size.y/2)
	current_scene = root.get_child(root.get_child_count() - 1)
	
	save_files_path = list_files_in_directory(save_folder_path)
	save_files_data = load_files_in_directory(save_folder_path)
	if current_scene.has_node("Menu"):
		current_scene.get_node("Menu").init(save_files_data)


func _process(delta):
	if Input.is_action_just_pressed("next_level"):
		print(current_scene.get_node(Niveau_path))
		stop_level()
		next_save()
		start_level()
		
	if Input.is_action_just_pressed("prev_level"):
		print(current_scene.get_node(Niveau_path))
		stop_level()
		prev_save()
		start_level()
	
	if Input.is_action_just_pressed("menu"):
		if is_menu:
			current_scene.get_node("Menu").visible = false
			start_level()
			is_menu = false
		else:
			is_menu = true
			stop_level()
			current_scene.get_node("Menu").visible = true

func load_save(path):
	level_from_save = true
	save_lib.load_file(current_scene, path)
	init_level()

func next_save():
	if level_from_save:
		save_index = (save_index+1) % len(save_files_path)
	var path = save_files_path[save_index]
	print(path)
	load_save(path)

func prev_save():
	if level_from_save:
		save_index -= 1
	if save_index < 0:
		save_index = len(save_files_path)-1
	var path = save_files_path[save_index]
	load_save(path)

func stop_level():
	current_scene.get_node(Niveau_path).set_physics_process(false)
	current_scene.get_node(Niveau_path).set_process(false)
	current_scene.get_node(Avatar_path).set_physics_process(false)
	current_scene.get_node(Avatar_path).set_process(false)
	current_scene.get_node(Niveau_path).clean_death_marks()
	current_scene.get_node(Camera_path).set_physics_process(false)
	current_scene.get_node(Camera_path).set_process(false)

func start_level():
	current_scene.get_node(Niveau_path).set_physics_process(true)
	current_scene.get_node(Niveau_path).set_process(true)
	current_scene.get_node(Avatar_path).set_physics_process(true)
	current_scene.get_node(Avatar_path).set_process(true)
	current_scene.get_node(Camera_path).set_physics_process(true)
	current_scene.get_node(Camera_path).set_process(true)

func init_level():
	var tilemap = current_scene.get_node(TileMap_path)
	tilemap.init()
	var avatar = current_scene.get_node(Avatar_path)
	avatar.death()
	avatar.init()
	var GUI = current_scene.get_node(GUI_path)
	GUI.init()
	var camera = current_scene.get_node(Camera_path)
	camera.init()


func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + "/" + file)

	dir.list_dir_end()
	return files



func load_files_in_directory(path):
	var datas=[]
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	while true:
		#print("-------")
		var file_path = dir.get_next()
		#print(file_path)
		if file_path == "":
			break
		elif not file_path.begins_with("."):
			var file = File.new()
			file_path = path + "/" + file_path
			#print(file_path)
			if file.file_exists(file_path):
				file.open(file_path, file.READ)
				var test_json_conv = JSON.new()
				test_json_conv.parse(file.get_as_text())
				var data_dict = test_json_conv.get_data()
				data_dict["file_path"] = file_path
				datas.append(data_dict)
				file.close()
				
	dir.list_dir_end()

	return datas

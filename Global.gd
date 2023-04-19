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

var has_touch_screen = false

var has_server_saves = false
var save_folder_path = "res://save/"
var save_server_url = ""
var save_files_path = []
var save_files_data = []
var save_index = 0

var is_menu = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var root = get_tree().get_root()
	base_size = get_viewport().size
	base_center = Vector2(base_size.x/2, base_size.y/2)
	current_scene = root.get_child(root.get_child_count() - 1)
	
	save_folder_path = current_scene.save_folder_path
	save_server_url = current_scene.save_server_url
	
	if OS.has_touchscreen_ui_hint():
		has_touch_screen = true
	
	if current_scene.has_node("Menu"):
		# load save from local "res://" file or from "server" 
		if OS.has_feature('JavaScript'):
			var http = HTTPRequest.new()
			current_scene.add_child(http)
			http.connect("request_completed", self, "_on_request_completed")
			http.request(save_server_url)
			yield(http, "request_completed")
		
		if has_server_saves == false:
			save_files_path = list_files_in_directory(save_folder_path)
			save_files_data = load_files(save_files_path)
		
		current_scene.get_node("Menu").init(save_files_data)
		yield(get_tree().create_timer(0.1), "timeout")
		set_save(save_files_data[0])

func _process(delta):
	if Input.is_action_just_pressed("toggle_full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen

	if current_scene.has_node("Menu"):
		if Input.is_action_just_pressed("next_level"):
			next_save()
		
		if Input.is_action_just_pressed("prev_level"):
			prev_save()
		
		if Input.is_action_just_pressed("menu"):
			if is_menu:
				current_scene.get_node("Menu").visible = false
				unpause_level()
				is_menu = false
			else:
				is_menu = true
				pause_level()
				current_scene.get_node("Menu/Control/save_files_list").select(save_index)
				current_scene.get_node("Menu").visible = true
				current_scene.get_node("Menu").get_node("%save_files_list").grab_focus()

func set_save(save_data):
	stop_level()
	level_from_save = true
	save_lib.set_data(current_scene, save_data)
	init_level()
	yield(get_tree().create_timer(1.0), "timeout")
	unpause_level()

func reload_save():
	set_save(save_files_data[save_index])

func next_save():
	if level_from_save:
		save_index = (save_index+1) % len(save_files_data)
	set_save(save_files_data[save_index])

func prev_save():
	if level_from_save:
		save_index -= 1
	if save_index < 0:
		save_index = len(save_files_data)-1
	set_save(save_files_data[save_index])

func stop_level():
	pause_level()
	current_scene.get_node(Niveau_path).clean_death_marks()

func pause_level():
	get_tree().paused = true

func unpause_level():
	get_tree().paused = false

func init_level():
	var tilemap = current_scene.get_node(TileMap_path)
	tilemap.init()
	
	var avatar = current_scene.get_node(Avatar_path)
	avatar.init()
	avatar.life()
	
	var GUI = current_scene.get_node(GUI_path)
	GUI.init()
	
	var camera = current_scene.get_node(Camera_path)
	camera.init()


func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + file)
	files.sort()
	return files

func load_files(files):
	var datas=[]
	for file_path in files:
		if file_path == "":
			break
		elif not file_path.begins_with("."):
			var file = File.new()
			if file.file_exists(file_path):
				file.open(file_path, file.READ)
				var data_dict = parse_json(file.get_as_text())
				data_dict["file_path"] = file_path
				datas.append(data_dict)
				file.close()
	return datas

func _on_request_completed(result, response_code, headers, body):
	print(result)
	if result == HTTPRequest.RESULT_SUCCESS:
		print("THE SAVES HAS BEEN LOADED FROM ANOTHER FILE ON SERVER")
		var json = JSON.parse(body.get_string_from_utf8())
		
		if json.error == OK:
			has_server_saves = true
			save_files_data = json.result
		else:
			print("BUT CAN'T PARSE JSON OR EMPTY:")
			print(body.get_string_from_utf8())
			

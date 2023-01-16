@tool
extends Node2D

signal var_changed
# variables du niveau (meta et narrative)
@export var groupe_name: String = "groupe" : set = _change_groupe_name
@export var date: Dictionary = {
	"year":2022,
	"month":0,
	"day":0,
	"hour":0
} : set = _change_date
@export var char_name: String = "" : set = _change_char_name
@export_multiline var narrative: String = "" : set = _change_narrative # (String, MULTILINE)

# variables persistantes entre les morts de l'Avatar
var start_position
var death_marks = []
# var persistant_active_triggers = []

func _ready():
	if not Engine.editor_hint:
		if Global.bool_start:
			print("before start")
			start()
			print("after start")

func start():
	start_position = $Avatar.start_position
	print("start")

func _input(event):
	if event.is_action_pressed("reset"):
		$Avatar.death()		
		$Avatar.start_position = $Avatar.original_start_position
		clean_death_marks()
		restart_level()
	if not Global.is_menu:
		if event is InputEventMouseButton and event.button_pressed == false and event.button_index == 1:
			$Avatar.position = get_local_mouse_position()

func restart_level():
	set_process(false)

	# reload tileMap
	var tileMap_scene = load("user://save_tileMap.tscn")
	var new_tileMap = tileMap_scene.instantiate()
	var name = $TileMap.name
	add_sibling($TileMap,new_tileMap)
	$TileMap.free()
	new_tileMap.set_name(name)
	print("restart")
	print($Avatar.position)
	#$Avatar.position = start_position
	$Avatar.life()
	#$Avatar.position = start_position
	print($Avatar.position)

func clean_death_marks():
	for mark in death_marks:
		mark.free()
	death_marks = []

func _on_Avatar_ready():
	if not Engine.editor_hint:
		$Camera2D.avatar = $Avatar
		$GUI.init()

# emit signal checked change checked editor for tools
func _change_groupe_name(new_value):
	groupe_name = new_value
	print(new_value)
	emit_signal("var_changed")

func _change_date(new_value):
	print(new_value)
	date = new_value
	emit_signal("var_changed")

func _change_char_name(new_value):
	print(new_value)
	char_name = new_value
	emit_signal("var_changed")

func _change_narrative(new_value):
	print(new_value)
	narrative = new_value
	emit_signal("var_changed")

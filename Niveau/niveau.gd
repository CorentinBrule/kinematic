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
@export var maintenant: bool = false : set = _now_date
@export var char_name: String = "" : set = _change_char_name
@export_multiline var narrative: String = "" : set = _change_narrative # (String, MULTILINE)

# variables persistantes entre les morts de l'Avatar
var start_position
var death_marks = []
# var persistant_active_triggers = []

func _ready():
	if not Engine.is_editor_hint():
		if Global.bool_start:
			print("before start")
			start()
			print("after start")

func start():
	start_position = $Avatar.start_position
	print("start")

func _input(event):
	if event.is_action_pressed("reset"):
		clean_death_marks()
		$Avatar.start_position = $Avatar.original_start_position
		$Avatar.death()
	
	if not Global.is_menu and not get_parent().has_node("Menu"):
		if event is InputEventMouseButton and event.pressed == false and event.button_index == 1:
			$Avatar.position = get_local_mouse_position()

func restart_level():
	# reload tileMap
	var tileMap_scene = load("user://save_tileMap.tscn")
	var new_tileMap = tileMap_scene.instantiate()
	var name = $TileMap.name
	$Trigger_end.add_sibling(new_tileMap) # add before $Avatar
	$TileMap.free()
	new_tileMap.set_name(name)
	
	$GUI/%win.hide()
	await get_tree().create_timer(1).timeout
	
	# restart Avatar
	print($Avatar.position)
	$Avatar.life()

func clean_death_marks():
	for mark in death_marks:
		mark.free()
	death_marks = []

func _on_Avatar_ready():
	if not Engine.is_editor_hint():
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

func _now_date(bool_now):
	if bool_now:
		var now_date = Time.get_datetime_dict_from_system()
		date.year = now_date.year
		date.month = now_date.month
		date.day = now_date.day
		date.hour = now_date.hour
		maintenant = false
		notify_property_list_changed()

func _change_char_name(new_value):
	print(new_value)
	char_name = new_value
	emit_signal("var_changed")

func _change_narrative(new_value):
	print(new_value)
	narrative = new_value
	emit_signal("var_changed")

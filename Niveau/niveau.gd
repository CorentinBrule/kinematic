tool
extends Node2D

signal var_changed
# variables du niveau (meta et narrative)
export(String) var groupe_name = "groupe" setget _change_groupe_name
export(Dictionary) var date = {
	"year":2022,
	"month":0,
	"day":0,
	"hour":0
} setget _change_date
export(bool) var maintenant = false setget _now_date
export(String) var char_name = "" setget _change_char_name
export(String, MULTILINE) var narrative = "" setget _change_narrative

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
		clean_death_marks()
		$Avatar.start_position = $Avatar.original_start_position
		$Avatar.death()
	
	if not Global.is_menu and get_parent().click_to_move:
		if event is InputEventMouseButton and event.pressed == false and event.button_index == 1:
			$Avatar.position = get_local_mouse_position()

func restart_level():
	# reload tileMap
	var tileMap_scene = load("user://save_tileMap.tscn")
	var new_tileMap = tileMap_scene.instance()
	var name = $TileMap.name
	add_child_below_node($TileMap,new_tileMap)
	$TileMap.free()
	new_tileMap.set_name(name)
	
	$"GUI/%win".hide()
	yield(get_tree().create_timer(1), "timeout")
	$Avatar.life()

func clean_death_marks():
	for mark in death_marks:
		mark.free()
	death_marks = []

func _on_Avatar_ready():
	if not Engine.editor_hint:
		$Camera2D.avatar = $Avatar
		$GUI.init()

# emit signal on change on editor for tools
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
		property_list_changed_notify()

func _change_char_name(new_value):
	print(new_value)
	char_name = new_value
	emit_signal("var_changed")

func _change_narrative(new_value):
	print(new_value)
	narrative = new_value
	emit_signal("var_changed")

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

@export_tool_button('Mettre à jour la date à "maintenant"', "Callable") var now_action = now_date
@export var char_name: String = "" : set = _change_char_name
@export_multiline var narrative: String = "" : set = _change_narrative # (String, MULTILINE)

# variables persistantes entre les morts de l'Avatar
var death_marks = []
# var persistant_active_triggers = []

func _ready():
	if not Engine.is_editor_hint():
		if get_parent().has_node("Menu") == false:
			$Avatar.set_process(false)
			$Avatar.set_process_input(false)
			$Avatar.set_physics_process(false)    
			await get_tree().create_timer(1).timeout
			$Avatar.life()

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
	var new_tileMap = tileMap_scene.instantiate()
	new_tileMap.is_new_level = false
	var node_name = $TileMap.name
	$Trigger_end.add_sibling(new_tileMap) # add before $Avatar
	$TileMap.free()
	new_tileMap.set_name(node_name)
	
	$GUI/%win.hide()
	#await get_tree().create_timer(1).timeout
	
	# restart Avatar
	print($Avatar.position)
	$Avatar.life()

func next_level():
	$Avatar.set_process(false)
	$Avatar.set_physics_process(false)
	$Camera2D.auto_cam = false
	$Camera2D.zoom_to_out()
	$GUI.prepare_text_transition(true)
	$TileMap.prepare_transition(true)

	while ($GUI.is_text_transition or $TileMap.is_level_transition):
		$Avatar.position = $Avatar.position.move_toward($Trigger_end.position + $Trigger_end/CollisionShape2D.get_shape().extents, 0.5)
		await get_tree().create_timer(0.05).timeout
	
	$Camera2D.auto_cam = true
	Global.next_save()

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

func now_date():
	var now_date = Time.get_datetime_dict_from_system()
	date.year = now_date.year
	date.month = now_date.month
	date.day = now_date.day
	date.hour = now_date.hour
	emit_signal("var_changed")
	notify_property_list_changed()

func _change_char_name(new_value):
	print(new_value)
	char_name = new_value
	emit_signal("var_changed")

func _change_narrative(new_value):
	print(new_value)
	narrative = new_value
	emit_signal("var_changed")


func _on_avatar_item_change() -> void:
	if not Engine.is_editor_hint(): 
		$GUI.init_items_actions()

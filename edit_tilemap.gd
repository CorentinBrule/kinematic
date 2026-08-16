#@tool ## was usefull to debug and edit theme of the Grid

extends Control

var tileMap_source_path := "/root/Jeu/Niveau/TileMap"
@onready var grid:ItemList = $"Node2D/Grid"
@onready var tiles:ItemList = $"%Tiles"
@onready var tileMap_source:TileMapLayer
@onready var tileMap:TileMapLayer = $"Node2D/TileMapLayer"

const save_lib = preload("res://save_lib.gd")

var textures = []
const nsize = 20  # grid size (if is a square)
const cell_offset = 2 # offset from the start of the cells (the wall)

var current_tile = -1

var editor_is_drawing := false
var editor_is_erasing := false

func _ready():
	var empty = load("res://Niveau/tileMap/empty.png")
	tileMap_source = get_node(tileMap_source_path)
	$"/root/Jeu/Niveau".level_changed.connect(_on_level_changed)
	grid.clear()
	tiles.clear()
	for i in range((nsize + cell_offset*2)*(nsize + cell_offset*2)):
		grid.add_icon_item(empty, false)
	
	var tileSet = tileMap_source.tile_set
	for i in range(tileSet.get_source_count()):
		var source = tileSet.get_source(i)
		textures.append(source.texture)
	
	for texture in textures:
		var file_name = texture.get_path().split("/")[-1]
		tiles.add_item(file_name,texture)
	tiles.select(0)
	select_tile(0)
	reload_tilemap()

## Copy cells to another tilemap 
func copy_tilemap_cells(source:TileMapLayer, target:TileMapLayer) -> void:
	target.clear()
	var new_tiles = source.get_used_cells()
	for t in new_tiles:
		var color_num = source.get_cell_source_id(t)
		target.set_cell(t, color_num, Vector2(0,0))

## Apply changes to ingame level
func test_tilemap() -> void:
	tileMap_source = get_node(tileMap_source_path)
	tileMap_source.is_new_level = false
	tileMap_source.apply_cells_from_tilemap(tileMap)
	## init manually the new tileMap cells for gameplay
	tileMap_source.init_lights()
	tileMap_source.fill_interactives()
	tileMap_source.save_tileMap("save_tileMap_interactive")
	tileMap_source.update_all_objs(true)

## Cancel all changes ! restore the level to what it was before the game starts
func reload_tilemap() -> void:
	var tileMap_saved = load("user://save_tileMap_editor.tscn")
	var new_tileMap:TileMapLayer = tileMap_saved.instantiate()
	
	copy_tilemap_cells(new_tileMap, tileMap)
	
	if tileMap.has_node("Walls"):
		tileMap.get_node("Walls").free()
	var new_walls = new_tileMap.find_child("Walls").duplicate()
	tileMap.add_child(new_walls)
	new_walls.collision_enabled = false
	new_walls.modulate = Color(1.0, 1.0, 1.0, 0.784)
	new_walls.name = "Walls"

func _on_tiles_item_selected(index: int) -> void:
	select_tile(index)

func select_tile(index: int) -> void:
	current_tile = index
	var texture = tiles.get_item_icon(index)
	var hovered_stylebox = grid.get_theme_stylebox("hovered")
	hovered_stylebox.set_texture(texture)
	grid.add_theme_stylebox_override("hovered", hovered_stylebox)

func _on_resized() -> void:
	if tiles:
		tiles.custom_maximum_size.x = max(16*2,get_viewport().size.x - ( Global.base_size.x * 0.9))

func _on_reload_button_pressed() -> void:
	reload_tilemap()
	test_tilemap()

func _on_level_changed() -> void:
	# triggered also by death ?
	reload_tilemap()

func _on_grid_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		$RightPanel/Container/SaveButton.disabled = true
		var targeted_coords = tileMap.local_to_map(event.position)
		if event.button_index == 1:
			tileMap.set_cell(targeted_coords, current_tile, Vector2i(0,0))
			editor_is_drawing = event.pressed
		if event.button_index == 2:
			tileMap.set_cell(targeted_coords, -1, Vector2i(0,0))
			editor_is_erasing = event.pressed
		if event.button_index == 3 and !event.pressed:
			var targeted_cel = tileMap.get_cell_source_id(targeted_coords)
			tiles.select(targeted_cel, true)
			select_tile(targeted_cel)
	if event is InputEventMouseMotion:
		#print(event.position)
		var targeted_coords = tileMap.local_to_map(event.position)
		if editor_is_drawing:
			tileMap.set_cell(targeted_coords, current_tile, Vector2i(0,0))
		elif editor_is_erasing:
			tileMap.set_cell(targeted_coords, -1, Vector2i(0,0))

func _on_test_button_pressed() -> void:
	test_tilemap()
	$RightPanel/Container/SaveButton.disabled = false

func _on_save_button_pressed() -> void:
	if Global.menu_external_saves:
		var save_path = Global.save_files_path[Global.save_index]
		save_lib.save_file(get_tree().get_current_scene(), save_path)
	else:
		## re apply cells without interactives...
		tileMap_source.apply_cells_from_tilemap(tileMap)
		var data_dict = save_lib.prepare_save(get_tree().get_current_scene())
		## using debugger and debugger plugin to update godot editor from the game
		EngineDebugger.send_message("kinematic:ingame_editor_save", [data_dict])
		## re init level to play
		test_tilemap()

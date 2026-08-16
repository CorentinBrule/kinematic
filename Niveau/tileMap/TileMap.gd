extends TileMapLayer

var is_new_level = true
var is_level_transition = false
var is_reverse_transition

var transition_range := 0.0
var transition_step = 0
var transition_duration := 2.0
var transition_direction := 1

var all_cells = []
var all_objs = []
var all_transition_steps:int

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Repères".hide()
	if is_new_level:
		init()

func init():
	save_tileMap("save_tileMap_editor")
	init_lights()
	fill_interactives()
	save_tileMap("save_tileMap_interactive")
	prepare_transition()

func _process(delta):
	if is_level_transition and not Engine.is_editor_hint():
		## strange for loop to process all transition elements (cells and objs) 
		## in both directions (appear or reverse) and time based
		var transition_speed = all_transition_steps / transition_duration * delta
		transition_range = transition_range + transition_speed * transition_direction
		
		for i in range(int(transition_step), int(transition_step+transition_range), transition_direction):
			if i >= 0 and i < all_cells.size():
				var cell = all_cells[i]
				if is_reverse_transition: # end level, hide the current tilemap
					set_cell(cell,5,Vector2i(0,0))
				else: # start level, reveal tilemap
					set_cell(cell,0,Vector2i(0,0))
				transition_step += transition_direction
				
			elif i >= all_cells.size() and i < all_transition_steps :
				if is_reverse_transition: # end level, hide the current tilemap
					all_objs[i - all_cells.size()].hide()
				else: # start level, reveal tilemap
					all_objs[i - all_cells.size()].show()
				transition_step += transition_direction
				
			else:
				$TileMap_lights.show()
				is_level_transition = false
			transition_range -= transition_direction

## update all obj list for easier external access
func update_all_objs(reverse:bool = false):
	all_objs.clear()
	for square in find_children("*","StaticBody2D",false,false):
		if reverse:
			all_objs.push_front(square)
		else:
			square.hide()
			all_objs.append(square)
	for checkpoint in find_children("Trigger*","",false,false):
		if reverse:
			all_objs.push_front(checkpoint)
		else:
			checkpoint.hide()
			all_objs.append(checkpoint)

func prepare_transition(reverse:bool = false):
	is_level_transition = true
	is_reverse_transition = reverse
	transition_range = 0
	$TileMap_lights.hide()
	
	update_all_objs(reverse)
	
	all_cells = get_used_cells()
	all_transition_steps = all_cells.size() + all_objs.size()

	if not reverse:
		transition_step = 0
		transition_direction = 1
		for cell in all_cells:
			set_cell(cell,5,Vector2i(0,0))
	else:
		transition_direction = -1
		transition_step = all_transition_steps - 1 

## init lights TileMap terrain
func init_lights():
	$TileMap_lights.show()
	$TileMap_lights.clear()
	var tiles_wall = $Walls.get_used_cells()
	$TileMap_lights.set_cells_terrain_connect(tiles_wall,0,0)
	var tiles = get_used_cells()
	var tiles_to_light = []
	for tile in tiles:
		if get_cell_source_id(tile) != 4: #if not a checkpoint
			tiles_to_light.append(tile)
	$TileMap_lights.set_cells_terrain_connect(tiles_to_light,0,0)

## convert interactive tiles into instances of interactive objects
func fill_interactives():
	clean_interactives()
	# peut-être load une seule fois ?
	var tilesize = rendering_quadrant_size
	var rouge = load("res://Niveau/tileMap/Rouge.tscn")
	var vert = load("res://Niveau/tileMap/Vert.tscn")
	var bleu = load("res://Niveau/tileMap/Bleu.tscn")
	var trigger = load("res://Niveau/tileMap/Trigger.tscn")
	
	var colors = ["",rouge,vert,bleu,trigger]
	var colors_name = ["","Rouge","Vert","Bleu","Trigger"]
	
	var tiles = get_used_cells()
	for t in tiles:
		var color_num = get_cell_source_id(t)
		if color_num > 0:
			var node = colors[color_num].instantiate()
			add_child(node)
			node.name = colors_name[color_num]
			node.position.x = t.x * tilesize + tilesize/2.0
			node.position.y = t.y * tilesize + tilesize/2.0
			set_cell(t, -1) # remove cell from tilemap
			node.set_owner(self)

## save tilemap as scene to reload when die
func save_tileMap(file_name:String):
	var packed_scene = PackedScene.new()
	packed_scene.pack(self)
	ResourceSaver.save(packed_scene, "user://"+ file_name +".tscn")

func clean_interactives():
	var children = get_children()
	for child in children:
		if child is StaticBody2D or child is Area2D:
			child.free()

func apply_cells_from_tilemap(source):
	clear()
	var new_tiles = source.get_used_cells()
	for t in new_tiles:
		var color_num = source.get_cell_source_id(t)
		set_cell(t, color_num, Vector2(0,0))

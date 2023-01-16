extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Repères".hide()
	# save tilemap from editor as scene to reload when die
	init()

func init():
	save_tileMap()
	fill_interactives()

# convertie les tuiles interactives en instance de scène d'éléments interactifs
func fill_interactives():
	clean_interactives()
	var tilesize = cell_size.x
	
	var rouge_tiles = get_used_cells_by_id(1)
	var rouge = load("res://Niveau/tileMap/Rouge.tscn")
	for t in rouge_tiles:
		var node = rouge.instance()
		add_child(node)
		node.position.x = t.x * tilesize + tilesize/2 
		node.position.y = t.y * tilesize + tilesize/2
		set_cell(t.x, t.y, -1)
#		node.set_owner(get_tree().edited_scene_root)
		
	var vert_tiles = get_used_cells_by_id(2)
	var vert = load("res://Niveau/tileMap/Vert.tscn")
	for t in vert_tiles:
		var node = vert.instance()
		add_child(node)
		node.position.x = t.x * tilesize + tilesize/2 
		node.position.y = t.y * tilesize + tilesize/2
		set_cell(t.x, t.y, -1)
#		node.set_owner(get_tree().edited_scene_root)
		
	var bleu_tiles = get_used_cells_by_id(3)
	var bleu = load("res://Niveau/tileMap/Bleu.tscn")
	for t in bleu_tiles:
		var node = bleu.instance()
		add_child(node)
		node.position.x = t.x * tilesize + tilesize/2 
		node.position.y = t.y * tilesize + tilesize/2
		set_cell(t.x, t.y, -1)
#		node.set_owner(get_tree().edited_scene_root)
	
	var trigger_tiles = get_used_cells_by_id(4)
	var trigger = load("res://Niveau/tileMap/Trigger.tscn")
	for t in trigger_tiles:
		var node = trigger.instance()
		add_child(node)
		node.position.x = t.x * tilesize + tilesize/2
		node.position.y = t.y * tilesize + tilesize/2
		set_cell(t.x, t.y, -1)
	
func save_tileMap():
	var packed_scene = PackedScene.new()
	packed_scene.pack(self)
	ResourceSaver.save("user://save_tileMap.tscn", packed_scene)

func clean_interactives():
	var children = get_children()
	for child in children:
		if child is StaticBody2D:
			child.queue_free()

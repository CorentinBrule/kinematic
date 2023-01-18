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
	var tilesize = cell_quadrant_size
	var rouge = load("res://Niveau/tileMap/Rouge.tscn")
	var vert = load("res://Niveau/tileMap/Vert.tscn")
	var bleu = load("res://Niveau/tileMap/Bleu.tscn")
	var trigger = load("res://Niveau/tileMap/Trigger.tscn")
	
	var colors = ["",rouge,vert,bleu,trigger]
	
	var tiles =  get_used_cells(0)
	for t in tiles:
		print(t)
		var color_num = get_cell_source_id(0,t)
		if color_num > 0:
			var node = colors[color_num].instantiate()
			add_child(node)
			node.position.x = t.x * tilesize + tilesize/2
			node.position.y = t.y * tilesize + tilesize/2
			set_cell(0, t, -1)
	
func save_tileMap():
	var packed_scene = PackedScene.new()
	packed_scene.pack(self)
	ResourceSaver.save(packed_scene, "user://save_tileMap.tscn")

func clean_interactives():
	var children = get_children()
	for child in children:
		if child is StaticBody2D:
			child.queue_free()

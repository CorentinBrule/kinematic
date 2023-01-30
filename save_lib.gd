extends RefCounted


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# customClass
const ItemClass = preload("res://Niveau/Avatar/Item.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Load & Set #
static func load_file(scene, path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var data_dict = test_json_conv.get_data()
		print(data_dict)
		set_data(scene, data_dict)

static func set_data(scene, data):
	set_meta_data(scene, data.get("meta"))
	set_story_data(scene, data.get("story"))
	set_tilemap_data(scene, data.get("level_tilemap"))
	set_character_data(scene, data.get("character"))


static func set_meta_data(scene, meta_data):
	var date = meta_data.date.split("-")
	scene.get_node("Niveau").date.year = date[0].to_int()
	scene.get_node("Niveau").date.month = date[1].to_int()
	scene.get_node("Niveau").date.day = date[2].to_int()
	scene.get_node("Niveau").date.hour = date[3].substr(0,2).to_int()
	scene.get_node("Niveau").groupe_name = meta_data.groupe_name


static func set_story_data(scene, story_data):
	scene.get_node("Niveau").char_name = story_data.char_name
	scene.get_node("Niveau").narrative = story_data.narrative


static func set_tilemap_data(scene, tilemap_data):
	var tilemap = scene.get_node("Niveau/TileMap")
	tilemap.clear()
	print(tilemap)
	for cell in tilemap_data:
		tilemap.set_cell(0, Vector2(cell.x, cell.y), cell.id, Vector2i(0,0))
	
static func set_character_data(scene, character_data):
	var character = scene.get_node("Niveau/Avatar")
	var properties = character_data.get("properties")
	for property in properties.keys():
		character[property] = properties[property]
	character["start_position"] = str_to_var("Vector2" + properties["start_position"])
	
	# hide old stuff
	for child in character.get_children():
		if child is ItemClass:
			child.set_visible(false)
	
	var stuff = character_data.get("stuff")
	set_stuff_data(scene, stuff)


static func set_stuff_data(scene, stuff_list):
	var character = scene.get_node("Niveau/Avatar")
	for obj in stuff_list:
		var item_node = character.get_node(obj.name)
		if item_node:
			item_node.set_visible(true)
			var properties = obj.get("properties")
			for property in properties.keys():
				item_node[property] = properties[property]
			print(properties["xbox_button"])
			item_node.set("xbox_button", properties.get("xbox_button"))

# Get & Save #

static func save_file(scene, path : String):
	var data_dict = {
		"meta":{
			"date":"",
			"groupe_name":""
		},
		"story":{
			"char_name":"",
			"narrative":"",
		},
		"character":{
			"objects":[],
			"variables":[]
		},
		"level_tilemap":[]
	}
	
	var niveau = scene.get_node("Niveau")
	data_dict.meta = get_meta_data(niveau)
	data_dict.story = get_story_data(niveau)

	var character = scene.get_node("Niveau/Avatar")
	data_dict.character = get_character_data(character)
	var tilemap = scene.get_node("Niveau/TileMap")
	data_dict.level_tilemap = get_tilemap_data(tilemap)

	#print(data_dict)
	var file = FileAccess.open(path, FileAccess.WRITE)

	file.store_string(JSON.stringify(data_dict,"\t"))


static func get_meta_data(niveau):
	# si pas de date ou jour ou mois = 0 : date de maintenant
	var date = niveau.date
	print(date)
	if date["day"] == 0 or date["month"] == 0:
		date = Time.get_datetime_dict_from_system()
	var data_date = "%04d-%02d-%02d-%02dh" % [date.year, date.month, date.day, date.hour]	
	# groupe_name
	var data_groupe = niveau.groupe_name
	
	return {"date":data_date, "groupe_name":data_groupe}

static func get_story_data(niveau):
	var char_name = niveau.char_name
	var narrative = niveau.narrative
	return {"char_name":char_name, "narrative":narrative}

static func get_tilemap_data(tilemap):
	var tilemap_data = []

	print(tilemap)
	var used_cells = tilemap.get_used_cells(0)
	for cell in used_cells:
		var cell_id = tilemap.get_cell_source_id(0,Vector2i(cell.x,cell.y))
		tilemap_data.append({
			"x":cell.x,
			"y":cell.y,
			"id":cell_id
		})
	return tilemap_data

static func get_character_data(character):
	var character_data = {
		"properties":{}
	}

	print(character)
	for property in get_exported_properties(character):
		character_data.properties[property.name] = character[property.name]
	
	var children = character.get_children()
	var stuff = []
	for child in children:
		print(child.name)
		print(child.get_class())
		if child is ItemClass: # if object is stuff
			if child.is_visible_in_tree(): # if is visible/active
				stuff.append(child)
	
	character_data.stuff = get_stuff_data(stuff)
	
	return character_data  

static func get_stuff_data(stuff):
	var stuff_data = []
	for obj in stuff:
		var obj_properties = {}
		for property in get_exported_properties(obj):
			obj_properties[property.name] = obj[property.name]
		stuff_data.append({
			"name":obj.get_name(),
			"properties":obj_properties
		})
	return stuff_data

static func get_exported_properties(object):
	var properties = object.get_property_list()
	var exported_properties = []
	for p in properties:
		if p.usage == 8199: # the way to know if a property is exported
			exported_properties.append(p)
	return exported_properties

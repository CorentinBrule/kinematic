extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var save_files
const color_textures = ["res://Niveau/tileMap/rouge.png","res://Niveau/tileMap/vert.png","res://Niveau/tileMap/bleu.png"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(list_save_files):
	save_files = list_save_files
	for save_file in list_save_files:
#		print(save_file.file_path)
#		print(save_file.meta.date)
		var clean_date = save_file.meta.date.split("-")
		if clean_date[3] == "00h":
			clean_date.remove_at(3)
		var clean_text = "/".join(clean_date)
		
		if save_file.meta.groupe_name != "":
			clean_text += " - " + save_file.meta.groupe_name
			
		if save_file.story.char_name != "":
			clean_text += " - " + save_file.story.char_name
		
		var color_id = save_file.character.properties.my_color
		var color_texture = load(color_textures[color_id])
		var idx = $"%save_files_list".add_item(clean_text, color_texture)
		$"%save_files_list".set_item_tooltip_enabled(idx, false)


func _on_save_files_list_item_activated(index):
	Global.set_save(save_files[index])
	Global.save_index = index
	Global.unpause_level()
	visible = false
	Global.is_menu = false

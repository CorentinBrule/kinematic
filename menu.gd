extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var save_files

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
			clean_date.remove(3)
		var clean_text = clean_date.join("/")
		
		if save_file.meta.groupe_name != "":
			clean_text += " - " + save_file.meta.groupe_name
			
		if save_file.story.char_name != "":
			clean_text += " - " + save_file.story.char_name
		
		$"%save_files_list".add_item(clean_text)


func _on_save_files_list_item_activated(index):
	Global.load_save(save_files[index]["file_path"])
	Global.unpause_level()
	visible = false
	Global.is_menu = false

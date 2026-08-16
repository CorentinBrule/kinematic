extends CanvasLayer
var audio_bus_name := "Master"
@onready var audio_bus := AudioServer.get_bus_index(audio_bus_name)

var audio_master_volume = 0.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var save_files
const color_textures = ["res://Niveau/tileMap/rouge.png","res://Niveau/tileMap/vert.png","res://Niveau/tileMap/bleu.png"]

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", Callable(self,"on_resize_window"))
	$%sliderAudio.value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus))
	%TabBar.set_tab_hidden(1, !Global.menu_external_saves)
	%TabBar.set_tab_hidden(2, !Global.menu_level_editor)

func init(list_save_files):
	$"%toggleFullScreen".button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
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
		var idx = %Save_files_list.add_item(clean_text, color_texture)
		%Save_files_list.set_item_tooltip_enabled(idx, false)


func _on_save_files_list_item_activated(index):
	Global.set_save(save_files[index])
	Global.save_index = index
	Global.unpause_level()
	visible = false
	Global.is_menu = false


func _on_save_files_list_item_selected(index):
	if Global.has_touch_screen:
		Global.set_save(save_files[index])
		Global.save_index = index
		Global.unpause_level()
		visible = false
		Global.is_menu = false


func exit_menu():
	Global.unpause_level()
	visible = false
	Global.is_menu = false

func _on_exitMenuButton_pressed():
	exit_menu()

func _on_toggleFullScreen_pressed():
	Global.toggle_full_screen()

func on_resize_window():
	# print(DisplayServer.screen_get_size())
	# print((DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN))
	$"%toggleFullScreen".button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_tab_bar_tab_changed(tab: int) -> void:
	$"Control/VBoxContainer/TabContainer".current_tab = tab

func _on_toggle_audio_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$%sliderAudio.value = audio_master_volume
	else:
		audio_master_volume = $%sliderAudio.value
		$%sliderAudio.value = 0.0

func _on_slider_audio_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audio_bus, linear_to_db(value))

func _on_slider_audio_drag_started() -> void:
	if %toggleAudio.button_pressed == false:
		%toggleAudio.button_pressed = true

func _on_toggle_effect_toggled(toggled_on: bool) -> void:
	Global.visual_effect = toggled_on

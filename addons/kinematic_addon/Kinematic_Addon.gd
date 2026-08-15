@tool
extends EditorPlugin

#var eds = get_editor_interface().get_selection()
var eds := EditorInterface.get_selection()

const MainPanel = preload("res://addons/kinematic_addon/main_panel.tscn")
const ItemClass = preload("res://Niveau/Avatar/Item.gd")

var main_panel_instance
var main_scene

func _enter_tree():
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	eds.connect("selection_changed", Callable(self, "_on_selection_changed"))
	scene_changed.connect(_on_scene_changed)
func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Importer & Savegarder Niveau"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")

func _on_selection_changed():
	var selected = eds.get_selected_nodes() 
	if len(selected) > 0:
		# Always pick first node in selection
		var selected_node = selected[0]
		if get_tree().get_edited_scene_root().name == "Jeu":
			if selected_node.name == "TileMap":
				selected_node.get_node("Repères").show()
				get_tree().get_edited_scene_root().get_node("Niveau/GUI/outGameGUI/cache_GUI_actions_input").show()
			else:
				get_tree().get_edited_scene_root().get_node("Niveau/TileMap/Repères").hide()
				get_tree().get_edited_scene_root().get_node("Niveau/GUI/outGameGUI/cache_GUI_actions_input").hide()

func _on_scene_changed(node):
	if node is ItemClass:
		ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color(0.785, 0.785, 0.785, 1.0))
	else: 
		ProjectSettings.set_setting("rendering/environment/defaults/default_clear_color", Color(0.0, 0.0, 0.0, 1.0))
	ProjectSettings.save()

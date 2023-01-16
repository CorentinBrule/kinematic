tool
extends EditorPlugin

var eds = get_editor_interface().get_selection()

const MainPanel = preload("res://addons/main_screen/main_panel.tscn")

var main_panel_instance

func _enter_tree():
	eds.connect("selection_changed", self, "_on_selection_changed")
	main_panel_instance = MainPanel.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func has_main_screen():
	return true


func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func get_plugin_name():
	return "Importer & Savegarder Niveau"


func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")


func _on_selection_changed():
	# Returns an array of selected nodes
	var selected = eds.get_selected_nodes() 

	if not selected.empty():
		# Always pick first node in selection
		var selected_node = selected[0]
		if get_tree().get_edited_scene_root().name == "Jeu":
			if selected_node.name == "TileMap":
				selected_node.get_node("%Repères").show()
			else:
				get_tree().get_edited_scene_root().get_node("Niveau/TileMap").get_node("%Repères").hide()

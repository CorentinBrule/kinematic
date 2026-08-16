extends Area2D
var transition = false

func _on_Trigger_end_body_entered(body):
	if body.name == "Avatar":
		if Global.menu_external_saves:
			get_parent().next_level()
		else:
			get_parent().get_node("GUI").get_node("%win").show()

extends Area2D

var active = false

func _ready():
	pass

func _on_Trigger_body_entered(body):
	if body.name == "Avatar":
		if not active:
			action()
			for node in get_parent().get_children():
				if "Trigger" in node.name:
					node.deactive()
			activate(body)

func action():
	var new_pos = Vector2(position.x , position.y)
	get_parent().get_parent().get_node("Avatar").start_position = new_pos 

func activate(body):
	active = true
	modulate = body.colors_val[body.my_color]

func deactive():
	active = false
	modulate = Color(1,1,1)

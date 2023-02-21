extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Trigger_end_body_entered(body):
	if body.name == "Avatar":
		if get_parent().get_parent().has_node("Menu"):
			Global.next_save()
		else:
			get_parent().get_node("GUI").get_node("%win").show()

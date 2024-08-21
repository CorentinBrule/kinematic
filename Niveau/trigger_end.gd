extends Area2D
var transition = false
var avatar
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	avatar = get_parent().get_node('Avatar')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if transition:
		avatar.position = avatar.position.move_toward(position + $CollisionShape2D.get_shape().extents, 0.2)

func _on_Trigger_end_body_entered(body):
	if body.name == "Avatar":
		if get_parent().get_parent().has_node("Menu"):
			var camera = get_parent().get_node('Camera2D')
			avatar.set_process(false)
			avatar.set_physics_process(false)
			var auto_cam = camera.auto_cam
			if auto_cam:
				camera.auto_cam = false
				camera.zoom_to_out()
			transition = true
			yield(get_tree().create_timer(1), "timeout")
			transition = false
			if auto_cam:
				camera.auto_cam = true
			Global.next_save()
		else:
			get_parent().get_node("GUI").get_node("%win").show()

extends Camera2D

@export var auto_cam:bool = false
@export var joystick_cam:bool = false

var avatar
var middle_pos = Vector2(192, 192)
var target_pos
var zoom_val = 1
var zoom_speed = 0.1
var min_zoom = Vector2(0.5, 0.5)
var max_zoom = Vector2(4, 4)
var mid_zoom = Vector2(1,1)
var zoom_dest = zoom
var edge_from_center
var clip_left_position_dest
var clip_left_width_dest
var clip_right_position_dest
var clip_right_width_dest
var clip_speed = 0.1
var clip_open = false
var clip_open_right = false
var zooming = false

func _ready():
	avatar = get_parent().get_node("Avatar")
	init()
	clip_left_position_dest = $ClipGauche.position.x
	clip_left_width_dest = $ClipGauche.size.x
	clip_right_position_dest = $ClipDroite.position.x
	clip_right_width_dest = $ClipDroite.size.x

func init():
	if !auto_cam:
		zoom_val = 0.5
	else:
		zoom_val = 1
		zoom_dest = min_zoom
		zoom = min_zoom
	$ClipGauche.position.x = get_viewport().size.x * -1
	$ClipDroite.position.x = get_viewport().size.x
	adapt_clip_destination()

func _input(event):
	if auto_cam:
		if event.is_action("move_bottom") or event.is_action("move_right") or event.is_action("move_left") or event.is_action("move_up") or event.is_action("Sauter"):
			if event.get_action_strength("move_bottom") > 0.5 or event.get_action_strength("move_right") > 0.5 or event.get_action_strength("move_left") > 0.5 or event.get_action_strength("move_up") > 0.5 or event.get_action_strength("Sauter") > 0.5:
				# il y a un truc que j'ai pas compris ave les zones mortes des joysticks...
				reset_zoom()
				open_clip_controls()
	
	if event.is_action("zoom_up_mouse"):
		zoom_in()
	if event.is_action("zoom_down_mouse"):
		zoom_out()
		
	if event.is_action("zoom_reset"):
		if zoom_val == 0.5 and clip_open_right == false:
			open_clip_controls()
		else:
			reset_zoom()

func _process(delta):
	
	if zoom_val < 0.5: 
		target_pos = lerp(avatar.position, middle_pos, zoom_val) 
	else: 
		target_pos = middle_pos

	if joystick_cam:
		if Input.is_action_pressed("zoom_up"):
			zoom_in(10)
		if Input.is_action_pressed("zoom_down"):
			zoom_out(10)
	
	
	
	if zoom_val > 0.5:
		open_clip()
	else:
		clip_open = false
	
	if zoom.distance_to(zoom_dest) > 0.005:
		zooming = true
		position = lerp(position, target_pos, 0.1)
	else: 
		zooming = false
		position = target_pos
	
	zoom = lerp(zoom,zoom_dest,0.05)
	update_clip()

func zoom_in(zoom_speed_changer=1):
	zoom_val = max(zoom_val - zoom_speed/zoom_speed_changer, 0)
	zoom_dest = calc_zoom_dest(max_zoom,min_zoom,zoom_val)
	adapt_clip_destination()
	#print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))

func zoom_out(zoom_speed_changer=1):
	zoom_val = min(zoom_val + zoom_speed/zoom_speed_changer, 1)
	zoom_dest = calc_zoom_dest(max_zoom,min_zoom,zoom_val)
	adapt_clip_destination()
	#print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))

func calc_zoom_dest(max_zoom,min_zoom,zoom_val):
	var _zoom_dest
	if zoom_val<0.5:
		_zoom_dest = lerp(max_zoom,mid_zoom,zoom_val)
	elif zoom_val>0.5:
		_zoom_dest = lerp(mid_zoom,min_zoom,zoom_val)
	elif zoom_val == 0.5:
		_zoom_dest = mid_zoom
	return _zoom_dest

func reset_zoom():
	zoom_dest = mid_zoom
	zoom_val = 0.5
	clip_open_right = false
	target_pos = middle_pos
	adapt_clip_destination()
#	print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))

func adapt_clip():
	adapt_clip_destination()
	if clip_open == false:
		force_update_clip()

func adapt_clip_destination():
	var resize_ratio = float(get_viewport().size.x) / float(get_viewport().size.y)
	if resize_ratio > 1 : # horizontal screen
		var resize_factor = float(get_viewport().size.y) / 384
		var resized_edge_from_center = float(get_viewport().size.x)/2
		edge_from_center = (resized_edge_from_center / resize_factor)
#		print("là:")
#		print(edge_from_center)
		var zoom_factor = 1/zoom_dest.x
		clip_left_position_dest = edge_from_center * -1 * zoom_factor - 5
		clip_left_width_dest =  edge_from_center * zoom_factor - 192 + 5
		clip_right_position_dest = 192 - 5
		clip_right_width_dest = edge_from_center * zoom_factor - 192 + 5

func update_clip():
	$ClipGauche.position.x = lerpf($ClipGauche.position.x, clip_left_position_dest, 0.05)
	$ClipGauche.size.x = lerpf($ClipGauche.size.x, clip_left_width_dest, 0.05)
	$ClipDroite.position.x = lerpf($ClipDroite.position.x, clip_right_position_dest, 0.05)
	$ClipDroite.size.x = lerpf($ClipDroite.size.x, clip_right_width_dest, 0.05)

func force_update_clip():
	$ClipGauche.position.x = clip_left_position_dest
	$ClipGauche.size.x = clip_left_width_dest
	$ClipDroite.position.x = clip_right_position_dest
	$ClipDroite.size.x = clip_right_width_dest

func open_clip():
	clip_open = true
	clip_left_width_dest = 0
	clip_right_position_dest = 192 + clip_right_width_dest
	
func open_clip_controls():
	clip_open_right = true
	clip_right_position_dest = 192 + clip_right_width_dest

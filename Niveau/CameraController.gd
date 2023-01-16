extends Camera2D

var avatar
var middle_pos = Vector2(192, 192)
var target_pos
var zoom_val = 1
var zoom_speed = 0.1
var max_zoom = Vector2(0.2, 0.2)
var min_zoom = Vector2(1.8, 1.8)
var zoom_dest = zoom
var edge_from_center
var clip_left_position_dest
var clip_left_width_dest
var clip_right_position_dest
var clip_right_width_dest
var clip_speed = 0.1
var clip_open = false
var clip_open_right = false

func _ready():
	# avatar = get_parent().get_node("Avatar")
	zoom_val = 0.5
	print("val: "+str(zoom_val)+" zoom: " + str(zoom))
	clip_left_position_dest = $ClipGauche.position.x
	clip_left_width_dest = $ClipGauche.size.x
	clip_right_position_dest = $ClipDroite.position.x
	clip_right_width_dest = $ClipDroite.size.x
	
func init():
	zoom_val = 0.5

func _process(delta):

	if zoom.x < 0.9: 
		target_pos = lerp(avatar.position, middle_pos, zoom_val) 
	else: 
		target_pos = middle_pos
	
	if Input.is_action_pressed("zoom_up"):
		zoom_in(10)
	if Input.is_action_pressed("zoom_down"):
		zoom_out(10)
		
	if Input.is_action_just_released("zoom_up_mouse"):
		zoom_in()
	if Input.is_action_just_released("zoom_down_mouse"):
		zoom_out()

	if Input.is_action_just_pressed("zoom_reset"):
		if zoom_val == 0.5 and clip_open_right == false:
			open_clip_controls()
		else:
			reset_zoom()
	if zoom_val > 0.5:
		open_clip()
	else:
		clip_open = false
#	if Input.is_action_just_released("zoom_up") or Input.is_action_just_released("zoom_down"):
#		position = lerp(position,target_pos,0.05)
#	else:
#		position = target_pos

	# if zooming ?
	position = lerp(position,target_pos,0.1)
	zoom = lerp(zoom,zoom_dest,0.05)
	$ClipGauche.position.x = lerp($ClipGauche.position.x, clip_left_position_dest, 0.05)
	$ClipGauche.size.x = lerp($ClipGauche.size.x, clip_left_width_dest, 0.05)
	$ClipDroite.position.x = lerp($ClipDroite.position.x, clip_right_position_dest, 0.05)
	$ClipDroite.size.x = lerp($ClipDroite.size.x, clip_right_width_dest, 0.05)

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
		_zoom_dest = lerp(max_zoom,Vector2(1,1),zoom_val)
	elif zoom_val>0.5:
		_zoom_dest = lerp(Vector2(1,1),min_zoom,zoom_val)
	elif zoom_val == 0.5:
		_zoom_dest = Vector2(1,1)
	return _zoom_dest

func reset_zoom():
	zoom_dest = Vector2(1.0,1.0)
	zoom_val = 0.5
	clip_open_right = false
	target_pos = middle_pos
	adapt_clip_destination()
#	print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))
	

func adapt_clip():
	print(clip_open)
	adapt_clip_destination()
	if clip_open == false:
		force_update_clip()

func adapt_clip_destination():
	var resize_ratio = get_viewport().size.x / get_viewport().size.y
	if resize_ratio > 1 : # horizontal screen
		var resize_factor = get_viewport().size.y / 384
		var resized_edge_from_center = (get_viewport().size.x)/2
		edge_from_center = (resized_edge_from_center / resize_factor)
#		print("là:")
#		print(edge_from_center)
		clip_left_position_dest = edge_from_center * -1 * zoom_dest.x - 5
		clip_left_width_dest =  edge_from_center * zoom_dest.x - 192 + 5
		clip_right_position_dest = 192 - 5
		clip_right_width_dest = edge_from_center * zoom_dest.x - 192 + 5

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

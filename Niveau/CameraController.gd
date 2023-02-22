extends Camera2D

var auto_cam = false
var joystick_zoom = false

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
var clip_open_left = false
var clip_open_right = true
var zooming = false

func _ready():
	avatar = get_parent().get_node("Avatar")
	clip_left_position_dest = $ClipGauche.rect_position.x
	clip_left_width_dest = $ClipGauche.rect_size.x
	clip_right_position_dest = $ClipDroite.rect_position.x
	clip_right_width_dest = $ClipDroite.rect_size.x
	init()

func init():
	if !auto_cam:
		zoom_val = 0.5
		reset_zoom()
		open_clip_controls()
	else:
		clip_open_left = true
		zoom_val = 1
		zoom_dest = min_zoom
		zoom = min_zoom
	adapt_clips()
	force_update_clip()

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
	
	if event.is_action_pressed("zoom_reset"):
		if zoom_val == 0.5 and clip_open_right == false:
			open_clip_controls()
		else:
			reset_zoom()
	
	print(zoom_val)
	if zoom_val > 0.5:
		open_clips()
	else:
		clip_open_left = false
		#clip_open_right = false
		adapt_clips()

func _process(delta):
	if zoom.x < 0.9: 
		target_pos = lerp(avatar.position, middle_pos, zoom_val) 
	else: 
		target_pos = middle_pos
	
	if joystick_zoom:
		if Input.is_action_pressed("zoom_up"):
			zoom_in(10)
		if Input.is_action_pressed("zoom_down"):
			zoom_out(10)
	
	if zoom.distance_to(zoom_dest) > 0.005:
		zooming = true
		position = lerp(position, target_pos, 0.4)
	else: 
		zooming = false
		position = target_pos
	
	zoom = lerp(zoom,zoom_dest,0.05)
	update_clip()

func zoom_in(zoom_speed_changer=1):
	zoom_val = max(zoom_val - zoom_speed/zoom_speed_changer, 0)
	zoom_dest = calc_zoom_dest(max_zoom,min_zoom,zoom_val)
	adapt_clips()
	#print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))

func zoom_out(zoom_speed_changer=1):
	zoom_val = min(zoom_val + zoom_speed/zoom_speed_changer, 1)
	zoom_dest = calc_zoom_dest(max_zoom,min_zoom,zoom_val)
	adapt_clips()
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
	clip_open_left = false
	target_pos = middle_pos
	adapt_clips()
#	print("val: "+str(zoom_val)+" zoom_dest: " + str(zoom_dest))

func adapt_clips():
	var resize_ratio = get_viewport().size.x / get_viewport().size.y
	if resize_ratio > 1 : # horizontal screen
		var resize_factor = get_viewport().size.y / 384
		var resized_edge_from_center = (get_viewport().size.x)/2
		edge_from_center = (resized_edge_from_center / resize_factor)
		
		clip_left_position_dest = (edge_from_center * -1 * zoom_dest.x) - 5		
		if clip_open_left == false:
			clip_left_width_dest =  (edge_from_center * zoom_dest.x - 192) + 5
		else:
			clip_left_width_dest = 0
		
		clip_right_width_dest = edge_from_center * zoom_dest.x - 192 + 5
		if clip_open_right == false:
			clip_right_position_dest = 192 - 5
		else:
			clip_right_position_dest = 192 + clip_right_width_dest

func update_clip():
	if(abs($ClipGauche.rect_position.x - clip_left_position_dest) > 0.5):
		$ClipGauche.rect_position.x = lerp($ClipGauche.rect_position.x, clip_left_position_dest, 0.05)
	if(abs($ClipGauche.rect_size.x - clip_left_width_dest) > 0.5):
		$ClipGauche.rect_size.x = lerp($ClipGauche.rect_size.x, clip_left_width_dest, 0.05)
	if(abs($ClipDroite.rect_position.x - clip_right_position_dest) > 0.5):
		$ClipDroite.rect_position.x = lerp($ClipDroite.rect_position.x, clip_right_position_dest, 0.05)
	if(abs($ClipDroite.rect_size.x - clip_right_width_dest) > 0.5):
		$ClipDroite.rect_size.x = lerp($ClipDroite.rect_size.x, clip_right_width_dest, 0.05)

func force_update_clip():
	$ClipGauche.rect_position.x = clip_left_position_dest
	$ClipGauche.rect_size.x = clip_left_width_dest
	$ClipDroite.rect_position.x = clip_right_position_dest
	$ClipDroite.rect_size.x = clip_right_width_dest

func open_clips():
	clip_open_left = true
	clip_open_right = true
	adapt_clips()

func open_clip_controls():
	clip_open_right = true
	adapt_clips()

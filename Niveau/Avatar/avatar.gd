@tool
extends CharacterBody2D

# customClass
const ItemClass = preload("res://Niveau/Avatar/Item.gd")

# Color effect
var colors_name = ["Rouge","Vert","Bleu"]
var colors_val = [Color(1,0,0,1),Color(0,1,0,1),Color(0,0,1,1)]
@export_enum("Rouge", "Vert", "Bleu") var my_color: set = change_color # (int, )
var color_bonus
var color_malus
# Member variables
@export var GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 200
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

#var velocity = Vector2()
var last_velocity = Vector2()

var bouncing = false
var attacking = false
var pushing = false
var safe = false

var jumping = false
var stop = false
var on_air_time = 100
var colle = false
var eat = false
var physic_direction = 0
var input_direction = 0
var old_pos = Vector2()

@export var start_position = Vector2(344,344) : set = change_start_position
var original_start_position

signal color_change
signal item_change

func _ready():
	init()

func init():
	original_start_position = start_position
	my_color = int(my_color)
	color_bonus  = (my_color + 1)%3
	color_malus = my_color - 1
	$Color.color = colors_val[my_color]

func _physics_process(delta):
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("autokill"):
			death()
		
		# if stuck in walls
		if get_slide_collision_count() == 4:
			print("stuck")
			position = old_pos
			get_node("AnimationDéplacement").seek(1,true)
			get_node("AnimationDéplacement").stop()

		# interaction with blocks
		for c in range(get_slide_collision_count()): 
			var collision = get_slide_collision(c)
			if collision.get_collider() != null:
				#print(collision.get_collider())
				var collision_color = collision.get_collider().name

				if collision_color == "TileMap":
					touch_plat(collision)
				#si même couleur
				elif collision_color.find(colors_name[my_color]) != -1 :
					touch_same(collision)
				#si couleur bonus
				elif collision_color.find(colors_name[color_bonus]) != -1:
					touch_bonus(collision)
				#si couleur malus
				elif collision_color.find(colors_name[color_malus]) != -1:
					touch_malus(collision)

		last_velocity = velocity
		
		# Create forces
		var force = Vector2(0, GRAVITY)
		
		var walk_left = Input.is_action_pressed("move_left")
		var walk_right = Input.is_action_pressed("move_right")
		
		stop = true
		
		if walk_left:
			input_direction = -1
			if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED: # and colle == false
				force.x -= WALK_FORCE
				stop = false
		elif walk_right:
			input_direction = 1
			if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED: #  and colle == false
				force.x += WALK_FORCE
				stop = false
		
		if sign(velocity.x) != 0:
			physic_direction = sign(velocity.x)
		
		if stop:
			var vsign = sign(velocity.x)
			var vlen = abs(velocity.x)
			
			vlen -= STOP_FORCE * delta
			if vlen < 0:
				vlen = 0
			
			velocity.x = vlen * vsign
		
		$debug_velocity_x.points[1].x = velocity.x
		$debug_velocity_y.points[1].y = velocity.y
		$debug_velocity.points[1] = velocity
		
		# Integrate forces to velocity
		velocity += force * delta
		# Integrate velocity into motion and move
		set_velocity(velocity)
		set_up_direction(Vector2(0, -1))
		move_and_slide()
		velocity = velocity
	
	else:
		start_position = position
	
func touch_plat(collision):
#	if pushing:
#		push(collision)
	pass
	

func touch_same(collision):
	#print("same")
	bounce(collision)
	
func touch_bonus(collision):
	#print("bonus")
	if eat:
		var col = collision.get_collider()
		attack(col)
	#bounce(collision)
	
func touch_malus(collision):
	#print("malus")
	if bouncing:
		bounce(collision)
	elif attacking:
		#print("attack")
		var col = collision.get_collider()
		attack(col)
#	elif safe:
#		if pushing:
#			push(collision)
	else :
		print("collision")
		#print(collision.get_type())
		death(collision)

	
func bounce(collision):
	if collision.normal.x == 0:
		if last_velocity.y > 10 or last_velocity.y < -10:
			velocity.y = last_velocity.y * -1
	if collision.normal.y == 0:
		velocity.x = last_velocity.x * -1

func death(collision=false):
	print("death")
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	velocity = Vector2(0,0)
	hide()
	
	if collision:
		var death_mark_scene = load("res://Niveau/deathMark.tscn")
		var death_mark = death_mark_scene.instantiate()
		death_mark.position = (position + collision.get_collider().position)/2
		get_parent().death_marks.append(death_mark)
		get_parent().add_child(death_mark)
	
	get_parent().restart_level()

func life():
	await get_tree().create_timer(1.0).timeout
	
	for item in get_active_items():
		item.reset()
	
	velocity = Vector2(0,0)
	position = start_position
	old_pos = start_position
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	show()

func attack(collider):
	collider.free()
	pass
#
#func push(collision):
#	if collision.normal.y == 0:
#		pushing = false
#		#print(collision.collider.position)
#		var tile_position = Vector2((collision.collider.position.x-8)/16,(collision.collider.position.y-8)/16)
#		#print(tile_position)
#		var next_tile = -collision.normal.x
#		print("next_tile:")
#		print(collision.collider.position.x+next_tile*16)
#		#print(get_node("/root/Niveau/TileMap").get_cell(tile_position.x+next_tile+next_tile,tile_position.y))
#		var tile_free = get_node("/root/Niveau/TileMap").get_cell(tile_position.x+next_tile,tile_position.y) == -1
#		var staticBody_free = true
#		for n in get_node("/root/Niveau").get_children():
#			if n.get_class() == "StaticBody2D":
#				if n.position.x == collision.collider.position.x+next_tile*16 and n.position.y == collision.collider.position.y:
#					staticBody_free = false
#
#		if tile_free and staticBody_free: 
#			if(collision.collider.name != "TileMap"):
#				collision.collider.move_local_x(next_tile*16)

func get_items():
	var items = []
	for child in get_children():
		if child is ItemClass:
			items.append(child)
	return items
	
func get_active_items():
	var items = []
	for child in get_children():
		if child is ItemClass and child.visible:
			items.append(child)
	return items

## changement live dans l'éditeur
func change_color(new_color):
	my_color = new_color
	emit_signal("color_change")

func _on_item_visibility_changed():
	emit_signal("item_change")

func _on_item_input_changed():
	emit_signal("item_change")

func change_start_position(value):
	start_position = value
	if Engine.is_editor_hint():
		position = start_position

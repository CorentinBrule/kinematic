extends ItemList

@onready var beat: Timer = $Beat
@onready var tilemap: TileMapLayer = get_parent().find_child("TileMap")
@onready var avatar = get_parent().find_child("Avatar")
@onready var trigger_end = get_parent().find_child("Trigger_end")

@onready var camera = get_parent().find_child("Camera2D")

var visibility_fade = 1 

const nsize = 20  # taille de la grille (si grille carrée)
const cell_offset = 2 # décalage du début des cellules dans la tilemap (le mur)
var step = 0 # étape du séquenceur
var cells = [] # liste des coordonneés des cellules ciblée par le sequenceur à l'étape x
var active_cells = [] #les murs de la tilemap = la basse
var active_interatives = [] #les éléments interactifs = la "mélodie"
var notes = []
var frequences = [
	32.70,
	36.71,
	41.20,
	43.65,
	49.00,
	55.00,
	61.74,
	65.41,
	73.42,
	82.41,
	87.31,
	98.00,
	110.0,
	123.5,
	130.8,
	146.8,
	164.8,
	174.6,
	196.0,
	220.0,
	246.9
]

var paused := false

@onready var bass_bus := AudioServer.get_bus_index("Bass")
@onready var main_bus := AudioServer.get_bus_index("Main")
var time_dependent_effects = []

var visual_delay = 0

func _ready():
	var texture = load("res://Niveau/tileMap/empty.png")
	for i in range(nsize*nsize):
		add_icon_item(texture)
	beat.timeout.connect(_on_beat)
	for note in range(nsize, 0, -1):
		var freq = frequences[note]
		notes.append(freq)
	
	# synchro des effets visuel avec les delais des AudioStreamGenerator
	visual_delay = get_instruments()[1].stream.buffer_length
	
	# lister les effets dépendant du temps (delay)
	for i in AudioServer.get_bus_effect_count(bass_bus):
		var effect = AudioServer.get_bus_effect(bass_bus,i)
		if effect is AudioEffectDelay:
			time_dependent_effects.append(effect)
	for i in AudioServer.get_bus_effect_count(main_bus):
		var effect = AudioServer.get_bus_effect(main_bus,i)
		if effect is AudioEffectDelay:
			time_dependent_effects.append(effect)
		
func _process(_delta):
	$Bass.pitch = remap(avatar.position.y,344,40,0.95,1.02)
	$Main.pitch = remap(avatar.position.y,344,40,0.95,1.02)
	if camera.zoom_val > 0.5:
		visibility_fade = lerpf(visibility_fade,1,0.01)
		modulate = Color(1,1,1,visibility_fade)
	else: 
		visibility_fade = lerpf(visibility_fade,0,0.1)
		modulate = Color(1,1,1,visibility_fade)
	
func restart():
	deselect_all()
	step = 0

func _on_beat():
	cells=[]
	active_cells = []
	active_interatives = []
	
	if !paused:
		#select_collumn(step:)
		select_collumn_invert(step)
		#select_row(step)
		## faire avancer l'étape du séquenceur
		step = (step+1)%nsize # boucle sur la grille (si grille carrée)
	
	for cell in cells:
		# corrige le décalage des cellules de la tilemap qui commencent après le mur 
		var cell_in_tilemap = Vector2i(cell.x+cell_offset,cell.y+cell_offset)
		var interactives = tilemap.all_objs
		for interactive in interactives:
			if interactive.position == tilemap.map_to_local(cell_in_tilemap):
				active_interatives.append(cell)
				continue
		if tilemap.get_cell_source_id(cell_in_tilemap) == 0:
			active_cells.append(cell)
		
	var next_bass_notes = []
	for cell in active_cells:
		next_bass_notes.append(notes[cell.y])
	var next_main_notes = []
	for cell in active_interatives:  
		next_main_notes.append(notes[cell.y]*2) 
	
	#$Bass.set_notes(next_bass_notes)
	arpeggio($Bass, next_bass_notes)
	#$Main.set_notes(next_main_notes)
	next_main_notes.shuffle()
	arpeggio($Main, next_main_notes)
	#for note in next_main_notes:
		#$Main.set_notes([note])
	
	var dist = avatar.position.distance_to(trigger_end.position)
	$Beat.wait_time = remap(dist,441,20,1.0,0.25) # il faut aussi changer les effets dépendant du temps sur le BUS
	#for effect in time_dependent_effects:
		#if effect is AudioEffectDelay:
			#effect.tap1_delay_ms = beat.wait_time*1000 / 4
			#effect.tap2_delay_ms = beat.wait_time*1000  / 2
			#print(effect.tap1_delay_ms)
	
	show_selection(visual_delay)

func arpeggio(instrument, notes_list):
	if notes_list.size() > 0:
		var time = $Beat.wait_time / notes_list.size()
		for n in notes_list:
			instrument.set_notes([n])
			await get_tree().create_timer(time).timeout
	else:
		instrument.set_notes([])

## "motif" du séquenceur colonne par colonne
func select_collumn(num):
	for r in range(nsize):
		cells.append(Vector2i(num,r))
		#var ncell = num + nsize*r
func select_collumn_invert(num):
	for r in range(nsize):
		cells.append(Vector2i(nsize-num,r))
		#var ncell = num + nsize*r

## "motif" du séquenceur ligne par ligne
func select_row(num):
	for c in range(nsize):
		cells.append(Vector2i(c,num))
		#var ncell = num*nsize + c
		#select(ncell,false)

func show_selection(delay = 0):
	await get_tree().create_timer(delay).timeout
	deselect_all()
	for c in cells:
		select(c.y*nsize + c.x,false)

func frequence(note:float,fondamentale=440.0):
	return fondamentale * pow(pow(2,1/12),note)

func mute_all():
	for instrument in get_instruments():
		instrument.mute()

func unmute_all():
	for instrument in get_instruments():
		instrument.unmute()

func get_instruments():
	var instruments = []
	for node in get_children():
		if node is AudioStreamPlayer:
			instruments.append(node)
	return instruments

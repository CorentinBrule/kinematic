extends AudioStreamPlayer
## audio stream generator : multi voices synth for additive synthesis 
## no envelope/ADSR yet
## synth "instrument" and osciloscope/waveform drawer is still on the same script for now

## params for synth
@onready var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().
var sample_hz := 22050.0/4 # Keep the number of samples to mix low, GDScript is not super fast.
var pitch := 1.0
var target_db := 0.0 # main volume

var voices = []

@export_group("Instrument")
@export_enum("sine","square","sawtooth","triangle") var wave_form = "sine"
@export_range(0.1,10.0) var texture := 1.0 # vague parameter, affect each wave_form differently
@export_enum("by_voices","normal","psychoacoustic") var gain_type = "by_voices" #how number of voices affect amplitude 
@export var gain := 1.0 # not sure if this parameter is "gain" but affect relation between number of voices and amplitude
var target_gain = 0.0

## params for osciloscope/waveform
@onready var scope := $Line2D
const BUFFER_SIZE = 8192
var waveform = PackedFloat32Array()
var write_index = 0

@export_group("Oscilloscope")
@export_enum("real_time","trigger") var scope_mode = "real_time"
# params for real_time mode
@export var time_window := 0.05 # seconds displayed # only for real time mode 
# params for trigger mode (suppose to be more fancy but bruh..)
@export_range(1,60) var periods_to_display = 4
@export var trigger_level := 0.0
@export var trigger_search = 200
var display_samples:int
@export_color_no_alpha var line_color = Color(1.0, 1.0, 1.0, 1.0)
var scope_w := 320 # base size
var scope_h := 320
var audio_delay_samples:int

func _ready():
	# Setting mix rate is only possible before play().
	scope.default_color = line_color
	audio_delay_samples = int(sample_hz * stream.buffer_length)
	display_samples = int(sample_hz * time_window)
	waveform.resize(BUFFER_SIZE)
	
	stream.mix_rate = sample_hz
	play()
	playback = get_stream_playback()
	# `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	_fill_buffer()

# main interface to play note
func note_on(freq):
	voices.append({
		"freq": freq,
		"phase": 0.0,
		"amp": 0.0,
		"target_amp": 0.5
	})

func note_off(freq):
	for v in voices:
		if v.freq == freq:
			v.target_amp = 0.0

func _fill_buffer():
	var frames_available = playback.get_frames_available()
	for i in range(frames_available):
		var sample = 0.0
		for v in voices:
			var increment =(v.freq * pitch) / sample_hz
			v.phase = fmod(v.phase + increment, 1.0)
			var osc:float
			if wave_form == "sine":
				osc = sin(v.phase * texture * TAU)
			elif wave_form == "sawtooth":
				osc = 2.0 * v.phase - 1.0
			elif wave_form == "square":
				osc = sign(sin(v.phase * TAU))
			elif wave_form == "triangle":
				osc = 4.0 * abs(v.phase - 0.5 * texture) - 1.0 
			# enveloppe simple
			if v.target_amp > v.amp:
				v.amp = lerp(v.amp, v.target_amp, 0.01)
			else:
				v.amp = lerp(v.amp, v.target_amp, 0.002)
		
			sample += osc * v.amp
		
		if gain_type == "by_voices":
			target_gain = lerp(target_gain, float(voices.size()),0.001)
			sample /= max(target_gain * gain, 0.5)
		elif gain_type == "normal":
			sample = sample * gain
		elif gain_type == "psychoacoustic":
			target_gain = lerp(target_gain, sqrt(max(voices.size(),1)),0.001)
			sample /= max(target_gain / gain,1)
		sample = clamp(sample, -0.9, 0.9) # avoid saturation
		
		playback.push_frame(Vector2.ONE * sample * 0.3)
		
		## save samples for waveform oscillosope
		waveform[write_index] = sample
		write_index = (write_index + 1) % BUFFER_SIZE

func _process(_delta):
	volume_db = lerp(volume_db, target_db, 0.01)
	_fill_buffer()

	# purge voices when amp is close to 0
	voices = voices.filter(func(v): return v.amp > 0.001 or v.target_amp > 0.0)
	
	# Oscilloscope
	if scope_mode == "real_time":
		update_scope_realtime()
	elif scope_mode == "trigger":
		update_scope_trigger()
	#fix modulate inherit
	scope.modulate = Color(
		scope.modulate.r, scope.modulate.g, scope.modulate.b, # keep line color
		get_parent().modulate.a # inherit alpha parent modulation
		)


func find_trigger_near(start):
	for i in range(trigger_search):

		var s1 = get_sample(start + i)
		var s2 = get_sample(start + i + 1)

		if s1 < trigger_level and s2 >= trigger_level:

			var frac = (trigger_level - s1) / (s2 - s1)
			return i + frac

	return 0

func get_sample(i):
	return waveform[(i + BUFFER_SIZE) % BUFFER_SIZE]

func find_trigger():
	for i in range(BUFFER_SIZE - 1):
		var s1 = get_sample(write_index + i)
		var s2 = get_sample(write_index + i + 1)
		if s1 < trigger_level and s2 >= trigger_level:
			var frac = (trigger_level - s1) / (s2 - s1)
			return i + frac
	return -1
	
func find_period(start):
	for i in range(int(start) + 1, BUFFER_SIZE - 1):
		var s1 = get_sample(write_index + i)
		var s2 = get_sample(write_index + i + 1)
		if s1 < trigger_level and s2 >= trigger_level:
			return i - start
	return -1

func update_scope_trigger():
	var trigger = find_trigger()
	if trigger < 0:
		return
	var period = find_period(trigger)
	if period <= 0:
		return
	var samples_to_draw = int(period * periods_to_display)

	var points = PackedVector2Array()
	points.resize(samples_to_draw)

	for i in range(samples_to_draw):
		var sample = get_sample(write_index + int(trigger) + i)
		var x = float(i) / samples_to_draw * scope_w
		var y = 0 - sample * scope_h/2 * 0.9
		points[i] = Vector2(x, y)

	scope.points = points

func update_scope_realtime():
	var start = write_index - display_samples - audio_delay_samples
	var offset = find_trigger_near(start)
	start += int(offset)
	var points = PackedVector2Array()
	points.resize(display_samples)
	
	for i in range(display_samples):
		var sample = get_sample(start + i)
		var x = float(i) / display_samples * scope_w
		var y = 0 - sample * scope_h/2 * 0.9
		points[i] = Vector2(x,y)
	
	$Line2D.points = points

func mute():
	target_db = -80.0
func unmute():
	target_db = 0.0

func set_notes(_list):
	# check if new notes is played
	for note in _list:
		var new_note = true
		for voice in voices:
			if note == voice["freq"] && voice["target_amp"] > 0.0:
				new_note = false
		if new_note:
			note_on(note)
	
	# check if old notes are released
	for voice in voices:
		var current_voice = false
		for note in _list:
			if voice["freq"] == note && voice["target_amp"] > 0.0:
				current_voice = true
		if !current_voice:
			note_off(voice["freq"])

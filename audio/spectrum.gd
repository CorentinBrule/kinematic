@tool
extends Node2D

@export var VU_COUNT := 50
@export var FREQ_MAX := 11050.0
@export var MIN_DB := 50
@export_color_no_alpha var color
enum AudioBus {}
@export var audio_bus: AudioBus

const spectrum_w = 400
const spectrum_h = spectrum_w/2
const h_scale = 8.0
const ANIMATION_SPEED = 0.2

var spectrum
var min_values = []
var max_values = []

func _ready():
	for i in AudioServer.get_bus_effect_count(audio_bus):
		var effect = AudioServer.get_bus_effect_instance(audio_bus,i)
		print(effect)
		if effect is AudioEffectSpectrumAnalyzerInstance:
			spectrum = effect
	if spectrum == null:
		printerr("No AudioEffectSpectrumAnalyzer in selected bus, or disabled")
	#spectrum = AudioServer.get_bus_effect_instance(0, 0)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)

func _draw():
	var w = spectrum_w / VU_COUNT
	for i in range(VU_COUNT):
		var min_height = min_values[i]
		var max_height = max_values[i]
		var height = lerp(min_height, max_height, ANIMATION_SPEED)

		#var color = Color.from_hsv(float(VU_COUNT * 0.6 + i * 0.5) / VU_COUNT, 0.5, 0.6)
		draw_rect(
			Rect2(w * i, spectrum_h - height, w - 1, height),
			color
		)
		

func _process(_delta):
	if !Engine.is_editor_hint():
		var data = []
		var prev_hz = 0

		for i in range(1, VU_COUNT + 1):
			var hz = i * FREQ_MAX / VU_COUNT
			var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
			
			var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
			var height = energy * spectrum_h * h_scale
			data.append(height)
			prev_hz = hz
		
		for i in range(VU_COUNT):
			if data[i] > max_values[i]:
				max_values[i] = data[i]
			else:
				max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)

			if data[i] <= 0.0:
				min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)
		# Sound plays back continuously, so the graph needs to be updated every frame.
		queue_redraw()

# tool method to export bus in editor
func _validate_property(property: Dictionary):
	print(property.name)
	if property.name == "audio_bus":
		var busNumber = AudioServer.bus_count
		var options = ""
		for i in busNumber:
			if i > 0:
				options += ","
			var busName = AudioServer.get_bus_name(i)
			options += busName
		property.hint_string = options

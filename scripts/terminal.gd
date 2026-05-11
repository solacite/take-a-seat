extends Control

@onready var sprite_3d_nodes: Array = [
	$SubViewport/Node3D/Sprite3D,
	$SubViewport/Node3D/Sprite3D2,
	$SubViewport/Node3D/Sprite3D3,
	$SubViewport/Node3D/Sprite3D4,
	$SubViewport/Node3D/Sprite3D5,
	$SubViewport/Node3D/Sprite3D6,
	$SubViewport/Node3D/Sprite3D7,
	$SubViewport/Node3D/Sprite3D8,
	$SubViewport/Node3D/Sprite3D9,
	$SubViewport/Node3D/Sprite3D10,
	$SubViewport/Node3D/Sprite3D11,
	$SubViewport/Node3D/Sprite3D12,
	$SubViewport/Node3D/Sprite3D13,
	$SubViewport/Node3D/Sprite3D14
]

@onready var feedback_label = $FeedbackLabel
@onready var floor_label = $FloorLabel
@onready var win_screen = $WinScreen
@onready var safe_area = $Safe
@onready var anomaly_area = $Anomaly

@export var normal_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (1).png")]
@export var anomaly_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (2).png")]
@export var anomaly_probability = 0.05
@export var feedback_timeout = 1.5
@export var total_floors = 10

var is_anomaly_map: Dictionary = {}
var current_floor = 1
var is_processing = false

func _ready():
	if safe_area:
		safe_area.connect("body_entered", Callable(self, "_on_safe_entered"))
	if anomaly_area:
		anomaly_area.connect("body_entered", Callable(self, "_on_anomaly_entered"))
	if win_screen:
		win_screen.hide()
	randomize_sprites()
	update_floor_label()
	if feedback_label:
		feedback_label.text = ""

func update_floor_label():
	if floor_label:
		floor_label.text = "Floor %d / %d" % [current_floor, total_floors]

func _on_safe_entered(body):
	if body.name == "Player" and not is_processing:
		if not is_any_anomaly():
			advance_floor("Floor clear!")
		else:
			fail_floor("There's an anomaly here...")

func _on_anomaly_entered(body):
	if body.name == "Player" and not is_processing:
		if is_any_anomaly():
			advance_floor("Anomaly found!")
		else:
			fail_floor("Nothing here. Stay alert.")

func advance_floor(message: String):
	is_processing = true
	if feedback_label:
		feedback_label.text = message
	await get_tree().create_timer(feedback_timeout).timeout
	if current_floor >= total_floors:
		show_win_screen()
		return
	current_floor += 1
	update_floor_label()
	if feedback_label:
		feedback_label.text = ""
	randomize_sprites()
	is_processing = false

func fail_floor(message: String):
	is_processing = true
	if feedback_label:
		feedback_label.text = message
	await get_tree().create_timer(feedback_timeout).timeout
	if feedback_label:
		feedback_label.text = ""
	randomize_sprites()
	is_processing = false

func show_win_screen():
	if win_screen:
		win_screen.show()
	if feedback_label:
		feedback_label.text = ""

func is_any_anomaly() -> bool:
	for sprite in is_anomaly_map.keys():
		if is_anomaly_map[sprite]:
			return true
	return false

func randomize_sprites():
	is_anomaly_map.clear()
	for sprite in sprite_3d_nodes:
		if sprite and sprite is Sprite3D:
			var is_anomaly = randf() < anomaly_probability
			is_anomaly_map[sprite] = is_anomaly
			if is_anomaly and anomaly_sprites.size() > 0:
				sprite.texture = anomaly_sprites[randi() % anomaly_sprites.size()]
			elif normal_sprites.size() > 0:
				sprite.texture = normal_sprites[randi() % normal_sprites.size()]
			sprite.transparent = true
			sprite.shaded = true
			sprite.pixel_size = 0.01
			var mat = StandardMaterial3D.new()
			mat.albedo_texture = sprite.texture
			mat.albedo_color = Color(0.45, 0.45, 0.45, 1.0)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			sprite.material_override = mat

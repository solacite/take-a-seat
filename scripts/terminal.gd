extends Control

@onready var sprite_3d_nodes: Array = [
	$Node3D/Sprite3D,
	$Node3D/Sprite3D2,
	$Node3D/Sprite3D3,
	$Node3D/Sprite3D4,
	$Node3D/Sprite3D5,
	$Node3D/Sprite3D6,
	$Node3D/Sprite3D7,
	$Node3D/Sprite3D8,
	$Node3D/Sprite3D9,
	$Node3D/Sprite3D10,
	$Node3D/Sprite3D11,
	$Node3D/Sprite3D12,
	$Node3D/Sprite3D13,
	$Node3D/Sprite3D14
]

@onready var feedback_label = $FeedbackLabel
@onready var floor_label = $FloorLabel
@onready var score_label = $ScoreLabel
@onready var win_screen = $WinScreen
@onready var safe_area = $Safe
@onready var anomaly_area = $Anomaly
@onready var player = $CharacterBody3D

@export var normal_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (1).png")]
@export var anomaly_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (2).png")]
@export var anomaly_probability = 0.05
@export var feedback_timeout = 1.5
@export var total_floors = 10

var is_anomaly_map: Dictionary = {}
var current_floor = 1
var score = 0
var is_processing = false
var player_start_position: Vector3

func _ready():
	if player:
		player_start_position = player.global_position
	else:
		push_error("player node not found")
	if safe_area:
		safe_area.connect("body_entered", Callable(self, "_on_safe_entered"))
	else:
		push_error("safe area not found")
	if anomaly_area:
		anomaly_area.connect("body_entered", Callable(self, "_on_anomaly_entered"))
	else:
		push_error("anomaly area not found")
	if win_screen:
		win_screen.hide()
	randomize_sprites()
	update_floor_label()
	update_score_label()
	if feedback_label:
		feedback_label.text = ""

func update_floor_label():
	if floor_label:
		floor_label.text = "flr %d / %d" % [current_floor, total_floors]

func update_score_label():
	if score_label:
		score_label.text = "score: %d" % score

func reset_player():
	if player:
		player.global_position = player_start_position
	else:
		push_error("cannot reset player - node is null")

func _on_safe_entered(body):
	print("safe entered by: ", body.name)
	if body.name == "CharacterBody3D" and not is_processing:
		if not is_any_anomaly():
			advance_floor("flr clear")
		else:
			fail_floor("anomaly present")

func _on_anomaly_entered(body):
	print("anomaly entered by: ", body.name)
	if body.name == "CharacterBody3D" and not is_processing:
		if is_any_anomaly():
			advance_floor("anomaly found")
		else:
			fail_floor("nothing here")

func advance_floor(message: String):
	is_processing = true
	score += 1
	update_score_label()
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
	reset_player()
	randomize_sprites()
	is_processing = false

func fail_floor(message: String):
	is_processing = true
	if feedback_label:
		feedback_label.text = message
	await get_tree().create_timer(feedback_timeout).timeout
	if feedback_label:
		feedback_label.text = ""
	reset_player()
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
			mat.albedo_color = Color(0.08, 0.08, 0.08, 1.0)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			sprite.material_override = mat

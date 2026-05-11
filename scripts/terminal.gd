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
@onready var safe_area = $Safe
@onready var anomaly_area = $Anomaly

@export var normal_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (1).png")]
@export var anomaly_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (2).png")]
@export var anomaly_probability = 0.05
@export var feedback_timeout = 1.5

var is_anomaly_map: Dictionary = {}
var level = 1

func _ready():
	if safe_area:
		safe_area.connect("body_entered", Callable(self, "_on_safe_entered"))
		safe_area.connect("body_exited", Callable(self, "_on_safe_exited"))

	if anomaly_area:
		anomaly_area.connect("body_entered", Callable(self, "_on_anomaly_entered"))
		anomaly_area.connect("body_exited", Callable(self, "_on_anomaly_exited"))

	randomize_sprites()

	if feedback_label:
		feedback_label.text = ""


func _on_safe_entered(body):
	if body.name == "Player":
		if not is_any_anomaly():
			handle_correct_choice("Safe! Level Up!")
		else:
			reset_level("It's not safe! Resetting to Level 1.")

func _on_safe_exited(body):
	if body.name == "Player":
		pass


func _on_anomaly_entered(body):
	if body.name == "Player":
		if is_any_anomaly():
			handle_correct_choice("Anomaly detected! Proceeding...")
		else:
			reset_level("No anomaly here. Back to Level 1!")

func _on_anomaly_exited(body):
	if body.name == "Player":
		pass


func handle_correct_choice(message: String):
	level += 1
	if feedback_label:
		feedback_label.text = message
	show_feedback_and_continue()

func reset_level(message: String):
	level = 1
	if feedback_label:
		feedback_label.text = message
	await get_tree().create_timer(feedback_timeout).timeout
	if feedback_label:
		feedback_label.text = ""
	randomize_sprites()

func show_feedback_and_continue():
	await get_tree().create_timer(feedback_timeout).timeout
	if feedback_label:
		feedback_label.text = ""
	randomize_sprites()

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

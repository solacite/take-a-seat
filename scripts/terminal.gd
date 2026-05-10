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
@onready var safe_area = $Safe  # Reference to the `Safe` Area3D node
@onready var anomaly_area = $Anomaly  # Reference to the `Anomaly` Area3D node

@export var normal_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (1).png")]
@export var anomaly_sprites: Array[Texture2D] = [load("res://images/Untitled_Artwork (2).png")]
@export var anomaly_probability = 0.05
@export var feedback_timeout = 1.5

var is_anomaly_map: Dictionary = {}  # Tracks which Sprite3D nodes have anomalies
var level = 1  # Current level

func _ready():
	if safe_area:
		safe_area.connect("body_entered", Callable(self, "_on_safe_entered"))
		safe_area.connect("body_exited", Callable(self, "_on_safe_exited"))
	else:
		print("Error: Safe Area3D is not connected to the scene.")

	if anomaly_area:
		anomaly_area.connect("body_entered", Callable(self, "_on_anomaly_entered"))
		anomaly_area.connect("body_exited", Callable(self, "_on_anomaly_exited"))
	else:
		print("Error: Anomaly Area3D is not connected to the scene.")

	randomize_sprites()  # Initialize random sprites
	if feedback_label:
		feedback_label.text = ""
	else:
		print("Error: Feedback Label node not found. Check node path.")


### Safe Area Logic ###
func _on_safe_entered(body):
	if body.name == "Player":  # Replace "Player" with your main character's node name
		if not is_any_anomaly():
			handle_correct_choice("Safe! Level Up!")
		else:
			reset_level("It's not safe! Resetting to Level 1.")

func _on_safe_exited(body):
	# Optional: Handle any actions when leaving the safe zone
	if body.name == "Player":
		pass


### Anomaly Area Logic ###
func _on_anomaly_entered(body):
	if body.name == "Player":
		if is_any_anomaly():
			handle_correct_choice("Anomaly detected! Proceeding...")
		else:
			reset_level("No anomaly here. Back to Level 1!")

func _on_anomaly_exited(body):
	# Optional: Handle any actions when leaving the anomaly zone
	if body.name == "Player":
		pass


### Game Logic ###
func handle_correct_choice(message: String):
	level += 1  # Increment the level
	if feedback_label:
		feedback_label.text = message
	show_feedback_and_continue()  # Proceed to next level


func reset_level(message: String):
	level = 1
	if feedback_label:
		feedback_label.text = message  # Display the feedback

	# Wait for feedback timeout, then clear feedback and reset sprites
	await get_tree().create_timer(feedback_timeout).timeout
	if feedback_label:
		feedback_label.text = ""
	randomize_sprites()  # Reset and randomize the Sprite3D nodes


func show_feedback_and_continue():
	# Display feedback before proceeding to the next level
	await get_tree().create_timer(feedback_timeout).timeout  # Wait
	if feedback_label:
		feedback_label.text = ""  # Clear the feedback text
	randomize_sprites()  # Move to the next level


func is_any_anomaly() -> bool:
	for sprite in is_anomaly_map.keys():
		if is_anomaly_map[sprite]:  # True if an anomaly exists
			return true
	return false


func randomize_sprites():
	# Assign random textures to Sprite3D nodes and update anomaly state
	is_anomaly_map.clear()

	for sprite in sprite_3d_nodes:
		if sprite and sprite is Sprite3D:
			var is_anomaly = randf() < anomaly_probability  # Randomly determine if it's an anomaly
			is_anomaly_map[sprite] = is_anomaly

			# Set texture based on whether it's an anomaly
			if is_anomaly and anomaly_sprites.size() > 0:
				sprite.texture = anomaly_sprites[randi() % anomaly_sprites.size()]
			elif normal_sprites.size() > 0:
				sprite.texture = normal_sprites[randi() % normal_sprites.size()]
		else:
			print("Error: Invalid Sprite3D node.")

extends CharacterBody3D

@export var speed = 5.0
@export var mouse_sensitivity = 0.2
@export var jump_strength = 10.0
@export var gravity = -24.8

@onready var camera = $Camera3D

var rotation_y = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity * 0.01)
		
		rotation_y -= event.relative.y * mouse_sensitivity * 0.01
		rotation_y = clamp(rotation_y, -1.2, 1.2)
		camera.rotation.x = rotation_y

func _physics_process(delta):
	apply_gravity(delta)
	process_movement(delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

func process_movement(delta):
	var input_dir = Vector3()
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_strength

	move_and_slide()

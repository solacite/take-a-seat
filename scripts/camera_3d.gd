extends Camera3D
@export var breathe_speed = 2.0
@export var breathe_amount = 0.08

@export var bob_speed = 12.0
@export var bob_amount = 0.12

@export var tilt_amount = 0.12
@export var tilt_speed = 12.0

var bob_time = 0.0
var breathe_time = 0.0
var current_tilt = 0.0
var base_position: Vector3
var last_bob_sign = 0.0

func _ready():
	base_position = position

func _process(delta):
	breathe_time += delta

	var breathe = sin(breathe_time * breathe_speed) * breathe_amount

	var velocity = get_parent().velocity
	var is_moving = Vector2(velocity.x, velocity.z).length() > 0.1

	if is_moving:
		bob_time += delta
	else:
		bob_time = lerp(bob_time, 0.0, delta * 5.0)

	var bob_y = sin(bob_time * bob_speed) * bob_amount
	var bob_x = sin(bob_time * bob_speed * 0.5) * bob_amount * 0.5

	position = base_position + Vector3(bob_x, breathe + bob_y, 0)

	var bob_sign = sign(sin(bob_time * bob_speed))
	if bob_sign != last_bob_sign and is_moving:
		position.y -= 0.04
	last_bob_sign = bob_sign

	var input_x = Input.get_axis("ui_left", "ui_right")
	var target_tilt = -input_x * tilt_amount
	current_tilt = lerp(current_tilt, target_tilt, delta * tilt_speed)
	rotation.z = current_tilt + sin(bob_time * bob_speed * 0.5) * 0.03

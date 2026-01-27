extends Area3D

# onready means that the var is reference only once it's finished loading :D
@onready var button = $"../Sprite3D/SubViewport/Button"

# handles when a mouse interacts with the collision shape under the area3D!
func _input_event(_camera: Camera3D, event: InputEvent, _click_position: Vector3, local_position: Vector3, _shape_idx: int) -> void:
	# make sure it only reacts to mouse clicks ;;
	if event is InputEventMouseButton and event.pressed:
		button.emit_signal("pressed")

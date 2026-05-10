extends Button


func _on_pressed() -> void:
	print("omg i got pressed")
	get_tree().change_scene_to_file("res://scenes/story.tscn")

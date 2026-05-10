extends Control

@onready var label = $Label
@onready var animation_player = $AnimationPlayer
@onready var button = $Button

@export var story_text_lines = [
	"Welcome to xx Airlines!",
	"As a flight attendant, you will be traveling with a very esteemed group of guests.",
	"There are 10 layovers.",
	"Make sure nothing goes awry.",
	"Keep them happy.",
	"Smile! You're on camera :)"
]

@export var typing_speed = 0.05

var current_line = 0
var text_index = 0
var is_typing = false
var skip_typing = false

func _ready():
	show_next_line()
	button.connect("pressed", Callable(self, "_on_click_continue"))

func _on_click_continue():
	if is_typing:
		skip_typing = true
	else:
		current_line += 1
		if current_line < story_text_lines.size():
			show_next_line()
		else:
			get_tree().change_scene_to_file("res://scenes/terminal.tscn")

func show_next_line():
	label.text = ""
	text_index = 0
	is_typing = true
	skip_typing = false
	_continue_typing()

func _continue_typing() -> void:
	if text_index < story_text_lines[current_line].length():
		if skip_typing:
			label.text = story_text_lines[current_line]
			is_typing = false
			return

		label.text += story_text_lines[current_line][text_index]
		text_index += 1

		await get_tree().create_timer(typing_speed).timeout
		if is_typing:
			_continue_typing()
	else:
		is_typing = false

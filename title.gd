extends Control

@onready var start = %Start
@onready var quit = %Quit

var village = preload("res://Maps/village.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start.grab_focus()

func _on_start_pressed():
	SceneManager.goto(village, "")

func _on_quit_pressed():
	get_tree().quit()

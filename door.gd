extends Area2D

@export var next_scene_string: String

var next_scene: PackedScene

var is_touching: bool

func _ready():
	next_scene = load("res://Maps/" + next_scene_string + ".tscn")

func _physics_process(delta):
	if InputScheme.is_action_just_pressed("up") and is_touching:
		SceneManager.goto(next_scene, "Door")

func _on_area_entered(area):
	is_touching = true

func _on_area_exited(area):
	is_touching = false

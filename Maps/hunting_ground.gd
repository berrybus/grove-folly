extends Node2D

@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.camera_2d.limit_bottom = 0
	player.camera_2d.limit_left = 0
	player.camera_2d.limit_top = -2944
	player.camera_2d.limit_right = 11776
